//
//  SalePropertyListController.m
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 10/29/13.
//  Copyright (c) 2013 Wu sicong. All rights reserved.
//

#import "SalePropertyListController.h"
#import "PropertyObject.h"
#import "PropertyDetailCell.h"
#import "SaleBidPlanController.h"

@interface SalePropertyListController ()

@end

@implementation SalePropertyListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        myArray = [NSMutableArray array];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitleViewWithString:@"选择房源"];
    
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
    myTable.delegate = self;
    myTable.dataSource = self;
    [self.view addSubview:myTable];
    
    PropertyObject *property1 = [[PropertyObject alloc] init];
    property1.title = @"昨天最好的房子";
    property1.communityName = @"天涯社区";
    property1.price = @"1万";
    [myArray addObject:property1];
    
    PropertyObject *property2 = [[PropertyObject alloc] init];
    property2.title = @"今天最好的房子";
    property2.communityName = @"明日论坛";
    property2.price = @"2万";
    [myArray addObject:property2];
    
    PropertyObject *property3 = [[PropertyObject alloc] init];
    property3.title = @"明天最好的房子";
    property3.communityName = @"黄浦江";
    property3.price = @"3.05万";
    [myArray addObject:property3];
    
    PropertyObject *property4 = [[PropertyObject alloc] init];
    property4.title = @"未来天最好的房子";
    property4.communityName = @"东方明珠";
    property4.price = @"6万";
    [myArray addObject:property4];
    
    PropertyObject *property = [[PropertyObject alloc] init];
    property.title = @"上海最好的房子";
    property.communityName = @"上海电视台";
    property.price = @"1.9亿";
    [myArray addObject:property];
    
	// Do any additional setup after loading the view.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SaleBidPlanController *controller = [[SaleBidPlanController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [myArray count];
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString *cellIdent = @"PropertyDetailCell";
        PropertyDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
        if(cell == Nil){
            cell = [[NSClassFromString(@"PropertyDetailCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PropertyDetailCell"];
            [cell setValueForCellByObject:[myArray objectAtIndex:[indexPath row]]];
        }
        return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
