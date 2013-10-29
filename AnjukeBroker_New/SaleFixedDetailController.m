//
//  SaleFixedDetailController.m
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 10/29/13.
//  Copyright (c) 2013 Wu sicong. All rights reserved.
//

#import "SaleFixedDetailController.h"
#import "FixedDetailCell.h"
#import "PropertyObject.h"
#import "PropertyListCell.h"
#import "NoPlanController.h"
#import "ModifyFixedCostController.h"
#import "SalePropertyDetailController.h"

@interface SaleFixedDetailController ()

@end

@implementation SaleFixedDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        myArray = [NSMutableArray array];
        fixedStatus = @"推广中     房源数：3套";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitleViewWithString:@"定价房源"];
    UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
    [action setTitle:@"操作" forState:UIControlStateNormal];
    [action addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchDown];
    [action setBackgroundColor:[UIColor lightGrayColor]];
    [action setFrame:CGRectMake(0, 0, 60, 40)];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:action];

    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
    myTable.delegate = self;
    myTable.dataSource = self;
    [self.view addSubview:myTable];
    FixedObject *fixed = [[FixedObject alloc] init];
    fixed.tapNum = @"10";
    fixed.topCost = @"100";
    fixed.totalCost = @"30";
    [myArray addObject:fixed];
    
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
    if([indexPath row] == 0){
    
    }else{
        SalePropertyDetailController *controller = [[SalePropertyDetailController alloc] init];
        controller.propertyObject = [myArray objectAtIndex:[indexPath row]];
        controller.fixedObject = [myArray objectAtIndex:0];
        [self.navigationController pushViewController:controller animated:YES];
    
    }
//    if(![selected containsObject:[myArray objectAtIndex:[indexPath row]]]){
//        [selected addObject:[myArray objectAtIndex:[indexPath row]]];
//        
//    }else{
//        [selected removeObject:[myArray objectAtIndex:[indexPath row]]];
//        
//    }
//    [myTable reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [myArray count];
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([indexPath row] == 0){
        static NSString *cellIdent = @"FixedDetailCell";
        FixedDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
        if(cell == Nil){
            cell = [[NSClassFromString(@"FixedDetailCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FixedDetailCell"];
            [cell setValueForCellByObject:[myArray objectAtIndex:[indexPath row]]];
        }
        return cell;
    }else{
        
        static NSString *cellIdent = @"PropertyListCell";
        PropertyListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
        if(cell == Nil){
            cell = [[NSClassFromString(@"PropertyListCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PropertyListCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell setValueForCellByObject:[myArray objectAtIndex:[indexPath row]]];
        }
        return cell;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 15)];
    headerLab.backgroundColor = [UIColor grayColor];
    headerLab.text = fixedStatus;
    return headerLab;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 55;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
//    contentView.backgroundColor = [UIColor grayColor];
//    
//    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
//    [delete setTitle:@"删除" forState:UIControlStateNormal];
//    delete.frame = CGRectMake(20, 10, 80, 35);
//    [contentView addSubview:delete];
//    
//    UIButton *multiSelect = [UIButton buttonWithType:UIButtonTypeCustom];
//    multiSelect.frame = CGRectMake(190, 10, 80, 35);
//    [multiSelect setTitle:@"定价推广" forState:UIControlStateNormal];
//    [contentView addSubview:multiSelect];
//    
//    return contentView;
//}
#pragma mark -- privateMethod
-(void)action{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加房源", @"停止推广", @"修改限额", nil];
    [action showInView:self.view];

}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        NoPlanController *controller = [[NoPlanController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if (buttonIndex == 1){
        fixedStatus = @"已停止推广     房源数：3套";
        [myTable reloadData];
    }else if (buttonIndex == 2){
        ModifyFixedCostController *controller = [[ModifyFixedCostController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
