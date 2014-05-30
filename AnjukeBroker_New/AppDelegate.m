//
//  AppDelegate.m
//  AnjukeBroker_New
//
//  Created by Wu sicong on 13-10-15.
//  Copyright (c) 2013年 Wu sicong. All rights reserved.
//

#import "AppDelegate.h"
#import "BK_RTNavigationController.h"
#import "LoginManager.h"
#import "ConfigPlistManager.h"
#import "AccountManager.h"
#import "AppManager.h"
#import "Reachability.h"
#import "AppManager.h"
#import "Util_UI.h"

#import "SaleNoPlanGroupController.h"
#import "RentNoPlanController.h"
#import "SaleBidDetailController.h"
#import "RentBidDetailController.h"
#import "RentFixedDetailController.h"
#import "SaleFixedDetailController.h"

#import "AXChatMessageCenter.h"
#import "HomeViewController.h"
#import "RushPropertyViewController.h"
#import "DiscoverViewController.h"
#import "RTGestureBackNavigationController.h"

#import "CrashLogUtil.h"

#define coreDataName @"AnjukeBroker_New"

#define UMENG_KEY_OFFLINE @"529da42356240b93f001f9b4"
#define UMENG_KEY_ONLINE @"52a0368c56240ba07800b4c0"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize rootViewController;
@synthesize loginVC;
@synthesize tabController;
@synthesize tabSwitchType;
@synthesize updateUrl;
@synthesize isEnforceUpdate;
@synthesize boolNeedAlert;

+ (AppDelegate *)sharedAppDelegate {
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.unReadPushCount = [UIApplication sharedApplication].applicationIconBadgeNumber; //记录未读消息总数
    
    [[BrokerLogger sharedInstance] logWithActionCode:AJK_ZONGHE_001 note:[NSDictionary dictionaryWithObjectsAndKeys:[Util_TEXT logTime], @"ot", nil]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    [self registerRemoteNotification];
    [self cleanRemoteNotification:application];
    
    //初始化底层库
    [self initRTManager];
    [self checkLogin];
    //监听每次连接长链接后-->获取最新未读消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewMessageCountForTab) name:@"MessageCenterConnectionStatusNotication" object:nil];
    //监听每次收到新消息提醒后-->获取最新未读消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewMessageCountForTab) name:MessageCenterDidReceiveNewMessage object:nil];
    //监听被踢出下线通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doLogOutEnforce) name:@"MessageCenterUserDidQuit" object:nil];
    
    //监听push
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushMessageCount) name:kMessageCenterReceiveNewPush object:nil];
    
    self.versionUpdate = [[VersionUpdateManager alloc] init];
    [self.versionUpdate checkVersion:YES];
    
    [self requestSalePropertyConfig];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIViewController *controller = [self returnVisibleViewControllerForController:self.window.rootViewController];
    if ([controller respondsToSelector:@selector(enterBackground)]) {
        [controller performSelector:@selector(enterBackground)];
    }
    
    //icon消息数处理
//    [self showAllNewMessageCountForIcon];
    
    //tell the service the count of unread messages if is login for chat
    if ([LoginManager isLogin] && [LoginManager getChatID].length > 0) {
        NSString *methodName = [NSString stringWithFormat:@"%@/%@/%ld", @"collectUnreadMessage", [LoginManager getChatID], (long)[[AXChatMessageCenter defaultMessageCenter] totalUnreadMessageCount] + self.propertyPushCount];
        [[RTRequestProxy sharedInstance] asyncRESTPostWithServiceID:RTAnjukeXUnreadServiceID methodName:methodName params:@{} target:self action:@selector(collectUnreadMessageDidFinished:)];
    }
    
    //断开长链接
    [self killLongLinkForChat];
    
//    [[RTLogger sharedInstance] sendCachedActions];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.unReadPushCount = [UIApplication sharedApplication].applicationIconBadgeNumber; //记录未读消息总数
    
    [self connectLongLinkForChat];
    
    [self cleanRemoteNotification:application];
    
    [[UpdateUserLocation shareUpdateUserLocation] fetchUserLocationWithComeletionBlock:^(BOOL updateLocationIsOk) {
    }];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CrashLogUtil writeCrashLog];
    });
    
    self.appDidBecomeActive = YES;
    
    self.old = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"messagePushCount"]) {
        self.old = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messagePushCount"] intValue];
    }
    
    self.propertyPushCount = self.unReadPushCount - self.old;
    if (self.propertyPushCount < 0 || (self.propertyPushCount == 0 && self.unReadPushCount == 0)) {
        self.propertyPushCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"propertyPushCount"] integerValue];
    }
    
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"did become active" message:[NSString stringWithFormat:@"总数%d, 旧值%d, 房源%d", self.unReadPushCount, self.old, self.propertyPushCount] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alert show];
    
    if (self.propertyPushCount > 0) {
        [self.tabController setDiscoverBadgeValueWithValue:[NSString stringWithFormat:@"%d", self.propertyPushCount]];
        RTGestureBackNavigationController* navi = [self.tabController.controllerArrays objectAtIndex:3];
        DiscoverViewController* dis = (DiscoverViewController*)[navi.viewControllers objectAtIndex:0];
        [dis setDiscoverBadgeValue:self.propertyPushCount];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.propertyPushCount] forKey:@"propertyPushCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    
    [self saveContext];
}
//强制被踢退出登录
- (void)doLogOutEnforce {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号已在其他设备上登录，请知悉" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [av show];
    [[AppDelegate sharedAppDelegate] doLogOut];
    [[AppDelegate sharedAppDelegate] killLongLinkForChat];
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AnjukeBroker_New" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AnjukeBroker_New.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Chat_Long_Link Method

//开始长链接
- (void)connectLongLinkForChat {
    //经纪人登录且获取微聊id和微聊token后才登录微聊
    if ([LoginManager getChatID].length > 0 && [LoginManager getChatToken].length > 0 && [LoginManager getToken].length > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_NOTIFICATION" object:nil];
    }
    [[AccountManager sharedInstance] registerNotification];
    
    //每次获取新消息数
    [self showNewMessageCountForTab];
}

- (void)killLongLinkForChat {
    [[AXChatMessageCenter defaultMessageCenter] breakLink]; //断开长链接方式
}

#pragma mark - Register Method
// 注册通知（声音、标记、弹出窗口）
- (void)registerRemoteNotification {
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [deviceToken description];
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:USER_DEFAULT_KEY_DEVICE_TOKEN]; //deviceToekn
    
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[AccountManager sharedInstance] setNotificationDeviceToken:token];
    [[AccountManager sharedInstance] registerNotification];
    
    DLog(@"device token: %@",token);
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[LoginManager getToken], @"token", nil];
    [params setObject:@"1" forKey:@"isNotification"];
    NSString *method = [@"tokenService/collectToken/" stringByAppendingString:token];
    [[RTRequestProxy sharedInstance] asyncRESTPostWithServiceID:RTBrokerRESTServiceID methodName:method params:params target:self action:@selector(onRequestFinished:)];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"推送" message:token delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alertView show];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DLog(@"didFailToRegisterForRemoteNotificationsWithError %@", [error description]);
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[LoginManager getToken], @"token", nil];
    [params setObject:@"0" forKey:@"isNotification"];
//    NSString *method = [@"tokenService/collectToken/" stringByAppendingString:token];
//    [[RTRequestProxy sharedInstance] asyncRESTPostWithServiceID:RTBrokerRESTServiceID methodName:method params:params target:self action:@selector(onRequestFinished:)];
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"推送" message:[error description] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alertView show];
}

- (void)cleanRemoteNotification:(UIApplication *)application{
//    self.unReadPushCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    self.propertyPushCount = self.unReadPushCount - [[AXChatMessageCenter defaultMessageCenter] totalUnreadMessageCount];
    
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
//    [self cleanRemoteNotification:application];
    
    if (application.applicationState == UIApplicationStateInactive) {
        DLog(@"userInfo [%@]", userInfo);
        NSString* msgType = [[userInfo objectForKey:@"anjuke_custom"] objectForKey:@"msgType"];
        if ([@"push" isEqualToString:msgType]) {
            
//            [self showPushMessageCount];
            //NSLog(@"弹出模态视图");
            RushPropertyViewController* viewController = [[RushPropertyViewController alloc] init];
            viewController.backType = RTSelectorBackTypeDismiss;
            [viewController setHidesBottomBarWhenPushed:YES];
            BK_RTNavigationController* navi = [[BK_RTNavigationController alloc] initWithRootViewController:viewController];
            if (self.tabController) {
                [self.tabController presentViewController:navi animated:YES completion:nil];
            }
            
            [[BrokerLogger sharedInstance] logWithActionCode:ENTRUST_ROB_PAGE_001 note:@{@"push":@"push"}];

        }
    }
    
}


#pragma mark -
#pragma mark Push Message Notification
- (void)showPushMessageCount{

    self.propertyPushCount++;  //计数器自增1
    if (self.propertyPushCount > 0) {
        [self.tabController setDiscoverBadgeValueWithValue:[NSString stringWithFormat:@"%d", self.propertyPushCount]];
        RTGestureBackNavigationController* navi = [self.tabController.controllerArrays objectAtIndex:3];
        DiscoverViewController* dis = (DiscoverViewController*)[navi.viewControllers objectAtIndex:0];
        [dis setDiscoverBadgeValue:self.propertyPushCount];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.propertyPushCount] forKey:@"propertyPushCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"房源自增1" message:[NSString stringWithFormat:@"房源%d", self.propertyPushCount] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alert show];
    
}


- (void)registerNotificationFinish:(RTNetworkResponse *)response{
    DLog(@"registerNotificationFinish %@", response.content);
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Private Method

- (void)initRTManager {
    //数据库初始化
    [[RTCoreDataManager sharedInstance] setModelName:coreDataName];
    
    //appLog初始化：app name, channelid, umeng key
    [[RTLogger sharedInstance] setConfig:RTLoggerConfigForBroker];
#ifdef DEBUG
    [[RTLogger sharedInstance] setUmengKey:UMENG_KEY_OFFLINE channelID:@"A01"];
#else
    [[RTLogger sharedInstance] setUmengKey:UMENG_KEY_ONLINE channelID:@"A01"];
#endif
    
    //网络请求初始化
    [[RTRequestProxy sharedInstance] setAppName:Code_AppName];
    [[RTRequestProxy sharedInstance] setChannelID:@"A01"];
    [[RTRequestProxy sharedInstance] setLogger:[RTLogger sharedInstance]];
    
    //gps定位信息
    [[RTLocationManager sharedInstance] restartLocation];
    
    [[UpdateUserLocation shareUpdateUserLocation] fetchUserLocationWithComeletionBlock:^(BOOL updateLocationIsOk) {
        DLog(@"updateStatus--->>%d",updateLocationIsOk);
    }];
}

- (void)checkLogin {
    //test add login
    LoginViewController *lb = [[LoginViewController alloc] init];
    self.loginVC = lb;
    BK_RTNavigationController *nav = [[BK_RTNavigationController alloc] initWithRootViewController:lb];
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
    
    if ([AppManager isFirstLaunch]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
        AFWelcomeScrollview *af = [[AFWelcomeScrollview alloc] initWithFrame:self.window.bounds];
        af.delegate = self;
        [af setImgArray:[NSArray arrayWithObjects:[UIImage imageNamed:@"anjuke_icon_ydy_1.png"], [UIImage imageNamed:@"anjuke_icon_ydy_2.png"], [UIImage imageNamed:@"anjuke_icon_ydy_3.png"], [UIImage imageNamed:@"anjuke_icon_ydy_4.png"], nil]];
        
        [nav.view addSubview:af];
    }
    else {
        [self registerRemoteNotification];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
}

- (BOOL)checkNetwork {
    // check if network is available
    if (![[RTRequestProxy sharedInstance] isInternetAvailiable]) {
        return NO;
    }
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    if ([r currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    
    return YES;
}

- (void)doLogOut {
    //    [self.window.rootViewController.navigationController popToRootViewControllerAnimated:YES];
    
    //退出登录：1.清空用户数据、2.断开长链接、3.推送API重新call（chatID为0传递）
    [self.loginVC doLogOut];
//    [self killLongLinkForChat];
    [[AXChatMessageCenter defaultMessageCenter] breakLink];
    [[AccountManager sharedInstance] cleanNotificationForLoginOut]; //退出登录（微聊）时，告之服务端
}

- (void)showMessageValueWithStr:(int)value { //显示消息条数
    
    if (self.old != value) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:value] forKey:@"messagePushCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //以下赋值逻辑只要在页面出现的时候走一次, 只有页面出现才走一次, 如果value与原来一样, 不走设置房源值逻辑
        if (self.appDidBecomeActive) {
            self.propertyPushCount = self.unReadPushCount - value;
            
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"message" message:[NSString stringWithFormat:@"总数%d, 新值%d", self.unReadPushCount, value] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//            [alert show];
            
            if (self.propertyPushCount < 0) {
                self.propertyPushCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"propertyPushCount"] integerValue];
            }
            
            if (self.propertyPushCount > 0) {
                [self.tabController setDiscoverBadgeValueWithValue:[NSString stringWithFormat:@"%d", self.propertyPushCount]];
                RTGestureBackNavigationController* navi = [self.tabController.controllerArrays objectAtIndex:3];
                DiscoverViewController* dis = (DiscoverViewController*)[navi.viewControllers objectAtIndex:0];
                [dis setDiscoverBadgeValue:self.propertyPushCount];
            }else{
                RTGestureBackNavigationController* navi = [self.tabController.controllerArrays objectAtIndex:3];
                DiscoverViewController* dis = (DiscoverViewController*)[navi.viewControllers objectAtIndex:0];
                navi.tabBarItem.badgeValue = nil;
                dis.badgeView.hidden = YES;
                
                if (self.propertyPushCount == 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"propertyPushCount"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }

            }
            
            self.appDidBecomeActive = NO;
        }
    }
    
    
    
    if (value <= 0) {
        [self.tabController setMessageBadgeValueWithValue:nil];
        return;
    }
    
    NSString *str = [NSString stringWithFormat:@"%d", value];
    
    if (value >= 100) {
        str = [NSString stringWithFormat:@"99+"];
    }
    [self.tabController setMessageBadgeValueWithValue:str];
    
    
}

- (void)showAllNewMessageCountForIcon {
    if ([LoginManager getChatID].length <= 0) {
        return;
    }
    
    //icon消息数处理
    //每次获取新消息数
    NSInteger count = [[AXChatMessageCenter defaultMessageCenter] totalUnreadMessageCount];
    if (count > 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    }
    else
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

//Tab显示
- (void)showNewMessageCountForTab {
    [[AXChatMessageCenter defaultMessageCenter] fetchConversationListItemWithFriendUID:[LoginManager getChatID]];
    
    NSInteger count = [[AXChatMessageCenter defaultMessageCenter] totalUnreadMessageCount];
    [self showMessageValueWithStr:count];
}

- (BOOL)checkHomeVCHasLongLinked {
    return [(HomeViewController *)self.tabController.HomeVC hasLongLinked];
}

#pragma mark - Request Method

//获取房源配置信息
- (void)requestSalePropertyConfig{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[LoginManager getCity_id], @"cityId", nil];
    
//    [[RTRequestProxy sharedInstance] asyncRESTPostWithServiceID:RTBrokerRESTServiceID methodName:@"anjuke/prop/getconfig/" params:params target:self action:@selector(onGetSaleSuccess:)];
    
    [[RTRequestProxy sharedInstance] asyncRESTGetWithServiceID:RTBrokerRESTServiceID methodName:@"anjuke/prop/getconfig/" params:params target:self action:@selector(onGetSaleSuccess:)];
}

- (void)onGetSaleSuccess:(RTNetworkResponse *)response {
    DLog(@"---er---response [%@]", [response content]);
    
    if ([response status] == RTNetworkResponseStatusFailed || [[[response content] objectForKey:@"status"] isEqualToString:@"error"]) {
//        NSString *errorMsg = [NSString stringWithFormat:@"%@",[[response content] objectForKey:@"message"]];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败" message:errorMsg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//        [alert show];
        
        return;
    }
    NSDictionary *resultFromAPI = [NSDictionary dictionaryWithDictionary:[[response content] objectForKey:@"data"]];
    
    //本地固化，处理二手房发房数据
    [ConfigPlistManager savePlistWithDic:resultFromAPI withName:AJK_ALL_PLIST];
    [ConfigPlistManager setAnjukeDataPlistWithDic:resultFromAPI];
    
    [self requestRentPropertyConfig];
}

- (void)requestRentPropertyConfig{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[LoginManager getCity_id], @"cityId", nil];
    
//    [[RTRequestProxy sharedInstance] asyncRESTPostWithServiceID:RTBrokerRESTServiceID methodName:@"zufang/prop/getconfig/" params:params target:self action:@selector(onGetRentSuccess:)];
    
    [[RTRequestProxy sharedInstance] asyncRESTGetWithServiceID:RTBrokerRESTServiceID methodName:@"zufang/prop/getconfig/" params:params target:self action:@selector(onGetRentSuccess:)];
    
}

- (void)onGetRentSuccess:(RTNetworkResponse *)response {
    DLog(@"---hz---response [%@]", [response content]);
    
    if ([response status] == RTNetworkResponseStatusFailed || [[[response content] objectForKey:@"status"] isEqualToString:@"error"]) {
//        NSString *errorMsg = [NSString stringWithFormat:@"%@",[[response content] objectForKey:@"message"]];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败" message:errorMsg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//        [alert show];
        
        return;
    }
    NSDictionary *resultFromAPI = [NSDictionary dictionaryWithDictionary:[[response content] objectForKey:@"data"]];
    
    //本地固化
    [ConfigPlistManager savePlistWithDic:resultFromAPI withName:HZ_ALL_PLIST];
    [ConfigPlistManager setHaozuDataPlistWithDic:resultFromAPI];
    
}

- (void)collectUnreadMessageDidFinished:(RTNetworkResponse *)response {
    DLog(@"collectUnreadMessageDidFinished [%@]", [response content]);
}

#pragma mark - Switch Method

- (void)dismissController:(UIViewController *)dismissController withSwitchIndex:(int)index withSwtichType:(TabSwitchType)switchType withPropertyDic:(NSDictionary *)propDic {
    [dismissController dismissViewControllerAnimated:NO completion:^(void){
        [self switchTabControllerWithIndex:index];
        
        [self doHomeNavPushWithSwitchIndex:index withSwtichType:switchType withPropertyDic:propDic];
    }];
}

- (void)switchTabControllerWithIndex:(int)index {
    if (!self.tabController) {
        return;
    }
    
    if (index >= self.tabController.controllerArrays.count) {
        return;
    }
    
    [self.tabController setSelectedIndex:index];
    
}

- (void)doHomeNavPushWithSwitchIndex:(int)index withSwtichType:(TabSwitchType)switchType withPropertyDic:(NSDictionary *)propDic {
    NSString *message = @"发布成功！";
    
    switch (switchType) {
        case SwitchType_RentFixed: //租房定价
        {
            RentFixedDetailController *controller = [[RentFixedDetailController alloc] init];
            controller.tempDic = propDic;
            controller.backType = RTSelectorBackTypePopToRoot;
            [controller setHidesBottomBarWhenPushed:YES];
            [[[self.tabController controllerArrays] objectAtIndex:index] pushViewController:controller animated:YES];
            [controller showTopAlertWithTitle:message];
        }
            break;
        case SwitchType_SaleFixed: //二手房定价
        {
            SaleFixedDetailController *controller = [[SaleFixedDetailController alloc] init];
            controller.tempDic = [NSMutableDictionary dictionaryWithDictionary:propDic];
            controller.backType = RTSelectorBackTypePopToRoot;
            [controller setHidesBottomBarWhenPushed:YES];
            [[[self.tabController controllerArrays] objectAtIndex:index] pushViewController:controller animated:YES];
            [controller showTopAlertWithTitle:message];
        }
            break;
        case SwitchType_RentBid: //租房竞价
        {
            RentBidDetailController *controller = [[RentBidDetailController alloc] init];
            [controller setHidesBottomBarWhenPushed:YES];
            [[[self.tabController controllerArrays] objectAtIndex:index] pushViewController:controller animated:YES];
            [controller showTopAlertWithTitle:message];
        }
            break;
        case SwitchType_SaleBid: //二手房竞价
        {
            SaleBidDetailController *controller = [[SaleBidDetailController alloc] init];
            [controller setHidesBottomBarWhenPushed:YES];
            [[[self.tabController controllerArrays] objectAtIndex:index] pushViewController:controller animated:YES];
            [controller showTopAlertWithTitle:message];
        }
            break;
        case SwitchType_RentNoPlan: //租房未推广
        {
            RentNoPlanController *controller = [[RentNoPlanController alloc] init];
            [controller setHidesBottomBarWhenPushed:YES];
            [[[self.tabController controllerArrays] objectAtIndex:index] pushViewController:controller animated:YES];
            [controller showTopAlertWithTitle:message];
        }
            break;
        case SwitchType_SaleNoPlan: //二手房未推广
        {
            SaleNoPlanGroupController *controller = [[SaleNoPlanGroupController alloc] init];
            [controller setHidesBottomBarWhenPushed:YES];
            [[[self.tabController controllerArrays] objectAtIndex:index] pushViewController:controller animated:YES];
            [controller showTopAlertWithTitle:message];
        }
            break;
            
        default:
            break;
    }
}

- (UIViewController *)returnVisibleViewControllerForController:(UIViewController *)controller {
    if ([controller presentedViewController]) {
        return [self returnVisibleViewControllerForController:[controller presentedViewController]];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self returnVisibleViewControllerForController:[(UITabBarController *)controller selectedViewController]];
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self returnVisibleViewControllerForController:[(UINavigationController *)controller topViewController]];
    } else {
        return controller;
    }
}

#pragma mark - AFWelcomeScrollViewDelegate

- (void)welcomeViewDidHide {
    [self registerRemoteNotification];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

@end
