//
//  BaseAuctionViewController.m
//  AnjukeBroker_New
//
//  Created by Wu sicong on 13-11-18.
//  Copyright (c) 2013年 Wu sicong. All rights reserved.
//

#import "BaseAuctionViewController.h"
#import "SaleAuctionViewController.h"
#import "RentAuctionViewController.h"
#import "BigZhenzhenButton.h"

@interface BaseAuctionViewController ()

@end

@implementation BaseAuctionViewController
@synthesize textField_1, textField_2;
@synthesize rangLabel;
@synthesize superVC;
@synthesize isHaozu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitleViewWithString:@"设置竞价"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method

- (void)initDisplay {
    //    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(doSure)];
    //    self.navigationItem.rightBarButtonItem = backBtn;
    
    [self addRightButton:@"确定" andPossibleTitle:nil];
    
    //draw input view
    for (int i = 0; i < 2; i ++) {
        [self drawInputBGWithIndex:i];
    }
        
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake([self windowWidth]/2, INPUT_VIEW_HEIGHT*2 + (20), [self windowWidth]/2, 30)];
    logoutBtn.backgroundColor = [UIColor clearColor];
    [logoutBtn addTarget:self action:@selector(checkRank) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutBtn];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"anjuke_icon_gupaiming.png"]];
    icon.frame = CGRectMake(logoutBtn.frame.size.width/3, (logoutBtn.frame.size.height - 15)/2, 17, 15);
    icon.userInteractionEnabled = YES;
    [logoutBtn addSubview:icon];
    
    UILabel *textLb = [[UILabel alloc] initWithFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width + 7, (logoutBtn.frame.size.height - 20)/2, 70, 20)];
    textLb.backgroundColor = [UIColor clearColor];
    textLb.text = @"预估排名";
    textLb.textColor = SYSTEM_ORANGE;
    textLb.font = [UIFont systemFontOfSize:15];
    [logoutBtn addSubview:textLb];
    
    UILabel *rankLb = [[UILabel alloc] initWithFrame:CGRectMake(0, logoutBtn.frame.origin.y, [self windowWidth]/2, 30)];
    rankLb.backgroundColor = [UIColor clearColor];
    rankLb.text = @"";
    rankLb.textColor = SYSTEM_LIGHT_GRAY;
    rankLb.textAlignment = NSTextAlignmentCenter;
    rankLb.font = [UIFont systemFontOfSize:15];
    self.rangLabel = rankLb;
    [self.view addSubview:rankLb];
}

- (void)drawInputBGWithIndex:(int)index {
    NSString *title = nil;
    NSString *placeStr = nil;
    
    if (index == 0) {
        title = @"预算";
        placeStr = @"最低20元";
    }
    else {
        title = @"出价";
        placeStr = @"";
    }
    
    UIView *BG = [[UIView alloc] initWithFrame:CGRectMake(0, 5 +index*(INPUT_VIEW_HEIGHT), [self windowWidth], INPUT_VIEW_HEIGHT)];
    BG.backgroundColor = [UIColor clearColor];
    [self.view addSubview:BG];
    
    CGFloat labelH = 20;
    
    UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_OFFSETX, (INPUT_VIEW_HEIGHT - labelH)/2, 50, labelH)];
    titleLb.backgroundColor = [UIColor clearColor];
    titleLb.text = title;
    titleLb.font = [UIFont systemFontOfSize:17];
    titleLb.textColor = SYSTEM_BLACK;
    [BG addSubview:titleLb];
    
    UITextField *cellTextField = nil;
    cellTextField = [[UITextField alloc] initWithFrame:CGRectMake(titleLb.frame.origin.x + titleLb.frame.size.width, 0,  [self windowWidth] - (titleLb.frame.origin.x + titleLb.frame.size.width)-10, BG.frame.size.height)];
    cellTextField.returnKeyType = UIReturnKeyDone;
    cellTextField.backgroundColor = [UIColor clearColor];
    cellTextField.borderStyle = UITextBorderStyleNone;
    cellTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cellTextField.text = @"";
    cellTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cellTextField.placeholder = placeStr;
    cellTextField.delegate = self;
    cellTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    cellTextField.font = [UIFont systemFontOfSize:17];
    cellTextField.textAlignment = NSTextAlignmentRight;
    cellTextField.secureTextEntry = NO;
    cellTextField.textColor = SYSTEM_LIGHT_GRAY;
    
    switch (index) {
        case 0:
        {
            self.textField_1 = cellTextField;
            self.textField_1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

        }
            break;
        case 1:
        {
            self.textField_2 = cellTextField;
            self.textField_2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
            break;
            
        default:
            break;
    }
    [BG addSubview:cellTextField];
    
    BrokerLineView *line = [[BrokerLineView alloc] initWithFrame:CGRectMake(TITLE_OFFSETX, INPUT_VIEW_HEIGHT - 0.5, [self windowWidth] - TITLE_OFFSETX, 0.5)];
    [BG addSubview:line];
    
}

- (void)checkRank {
    
}

#pragma mark - Request Method

-(void)doCheckRankWithPropID:(NSString *)propID commID:(NSString *)commID {
    if (![self isNetworkOkayWithNoInfo]) {
        [[HUDNews sharedHUDNEWS] createHUD:@"无网络连接" hudTitleTwo:nil addView:self.view isDim:NO isHidden:YES hudTipsType:HUDTIPSWITHNetWorkBad];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[LoginManager getToken], @"token", [LoginManager getUserID], @"brokerId", [LoginManager getCity_id], @"cityId", propID, @"propId", commID, @"commId", self.textField_2.text, @"offer", nil];
    
    if (self.isHaozu) {
        [[RTRequestProxy sharedInstance] asyncRESTPostWithServiceID:RTBrokerRESTServiceID methodName:@"zufang/bid/getrank/" params:params target:self action:@selector(onCheckSuccess:)];
    }
    else
        [[RTRequestProxy sharedInstance] asyncRESTPostWithServiceID:RTBrokerRESTServiceID methodName:@"anjuke/bid/getrank/" params:params target:self action:@selector(onCheckSuccess:)];
    [self showLoadingActivity:YES];
    self.isLoading = NO;
}

- (void)onCheckSuccess:(RTNetworkResponse *)response {
    DLog(@"------response [%@]", [response content]);
    if([[response content] count] <1){
        [self hideLoadWithAnimated:YES];
        self.isLoading = NO;
        return ;
    }
    if ([response status] == RTNetworkResponseStatusFailed || [[[response content] objectForKey:@"status"] isEqualToString:@"error"]) {
        NSString *errorMsg = [NSString stringWithFormat:@"%@",[[response content] objectForKey:@"message"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败" message:errorMsg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        [self hideLoadWithAnimated:YES];
        self.isLoading = NO;
        return;
    }
    
    NSDictionary *resultFromAPI = [NSDictionary dictionaryWithDictionary:[response content]];
    if ([response status] == RTNetworkResponseStatusFailed || [[[response content] objectForKey:@"status"] isEqualToString:@"error"]) {
        NSString *errorMsg = [NSString stringWithFormat:@"%@",[[response content] objectForKey:@"message"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败" message:errorMsg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        [self hideLoadWithAnimated:YES];
        self.isLoading = NO;
        return;
    }
    [self hideLoadWithAnimated:YES];
    self.isLoading = NO;
    self.rangLabel.alpha = 0.0;
    //test
    if([self.superVC isKindOfClass:[SaleAuctionViewController class]]){
    
    
    }
    self.rangLabel.text = [NSString stringWithFormat:@"预估排名:第%@位",[resultFromAPI objectForKey:@"data"]];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.rangLabel.alpha = 1;
    [UIView commitAnimations];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.textField_1]) {
        DLog(@"预算");
    }
    else if ([textField isEqual:self.textField_2]) {
        DLog(@"竞价");
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField_1 resignFirstResponder];
    [self.textField_2 resignFirstResponder];
    
    return YES;
}

@end
