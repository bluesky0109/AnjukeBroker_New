//
//  PPCGroupCell.m
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 10/29/13.
//  Copyright (c) 2013 Wu sicong. All rights reserved.
//

#import "PPCGroupCell.h"
#import "SaleFixedGroupObject.h"
#import "LoginManager.h"
#import "Util_UI.h"

@implementation PPCGroupCell
@synthesize statueImg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

//        [self.contentView addSubview:status];
        // Initialization code
    }
    return self;
}
-(void)initUI{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 66.0)];
    view.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:view];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(26, 10, 310, 20)];
    title.font = [UIFont systemFontOfSize:18];
    [self.contentView addSubview:title];
    
    detail = [[UILabel alloc] initWithFrame:CGRectMake(26, 35, 310, 20)];
    detail.textColor = [Util_UI colorWithHexString:@"#999999"];
    detail.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:detail];
    
    statueImg = [[UIImageView alloc] initWithFrame:CGRectMake(230, 25, 50, 20)];
    [self.contentView addSubview:statueImg];
    
    status = [[UILabel alloc] initWithFrame:CGRectMake(230, 25, 50, 20)];
    status.textColor = [UIColor whiteColor];
    status.font = [UIFont systemFontOfSize:12];
}
-(void)setValueForCellByData:(id ) data index:(int) index isHz:(BOOL)isHz{
    if([data isKindOfClass:[NSArray class]]){
        NSArray *tempArray = (NSArray *)data;
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        
        if(index == 0){
            title.text = @"竞价房源";
            if (isHz) {
                detail.text = [NSString stringWithFormat:@"房源数:%@套", [dic objectForKey:@"hzBidHouseNum"]];
            }else{
                detail.text = [NSString stringWithFormat:@"房源数:%@套", [dic objectForKey:@"ajkBidHouseNum"]];
            }
        } else if (index == [data count] - 1){//未推广
            title.text = @"待推广房源";
            if (isHz) {
                detail.text = [NSString stringWithFormat:@"房源数:%@套", [dic objectForKey:@"hzNotFixHouseNum"]];
            }else{
                detail.text = [NSString stringWithFormat:@"房源数:%@套", [dic objectForKey:@"ajkNotFixHouseNum"]];
            }

        }else{//定价
            title.text = @"定价房源";
            detail.text = [NSString stringWithFormat:@"%@ 房源数:%@套", [dic objectForKey:@"fixName"], [dic objectForKey:@"fixNum"]];
        }
        
        if ([[dic objectForKey:@"type"] intValue] == 1) {
            statueImg.image = nil;
        }else{
            if([[dic objectForKey:@"fixStatus"] intValue] == 1){
                statueImg.frame = CGRectMake(260, 27, 30, 13);
                [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_woking.png"]];
            }else{
                statueImg.frame = CGRectMake(260, 27, 30, 13);
                [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_stop.png"]];
            }
        }
    }
}

-(void)setFixedGroupValueForCellByData:(id ) data index:(int) index{
    if([data isKindOfClass:[NSArray class]]){
        NSArray *tempArray = (NSArray *)data;
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        title.text = @"定价房源";
        detail.text = [NSString stringWithFormat:@"%@ 房源数:%@套", [dic objectForKey:@"fixName"], [dic objectForKey:@"fixNum"]];
        //[dic objectForKey:@"fixPlanPropCeiling"]
        // 日限额:%@元
        if([[dic objectForKey:@"fixStatus"] intValue] == 1){
            statueImg.frame = CGRectMake(260, 27, 30, 13);
            [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_woking.png"]];
        }else{
            statueImg.frame = CGRectMake(260, 27, 30, 13);
            [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_stop.png"]];
        }
    }
}
-(void)setFixedGroupValueForCellByData:(id ) data index:(int) index isAJK:(BOOL) isAJK{
    if([data isKindOfClass:[NSArray class]]){
        NSArray *tempArray = (NSArray *)data;
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        title.text = @"定价房源";
        if([LoginManager isSeedForAJK:isAJK]){//判断播种城市,yes-->二手房
            detail.text = [NSString stringWithFormat:@"%@ 房源数:%@套 每日最高花费:%@元", [dic objectForKey:@"fixPlanName"], [dic objectForKey:@"fixPlanPropNum"], [dic objectForKey:@"fixPlanPropCeiling"]];
        }else{
            detail.text = [NSString stringWithFormat:@"%@ 房源数:%@套", [dic objectForKey:@"fixPlanName"], [dic objectForKey:@"fixPlanPropNum"]];
        }
        //, [dic objectForKey:@"fixPlanPropCeiling"]
        //, [dic objectForKey:@"fixPlanPropCeiling"]
        if([[dic objectForKey:@"fixStatus"] intValue] == 1){
            statueImg.frame = CGRectMake(260, 27, 30, 13);
            [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_woking.png"]];
        }else{
            statueImg.frame = CGRectMake(260, 27, 30, 13);
            [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_stop.png"]];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
