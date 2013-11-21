//
//  PPCGroupCell.m
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 10/29/13.
//  Copyright (c) 2013 Wu sicong. All rights reserved.
//

#import "PPCGroupCell.h"
#import "SaleFixedGroupObject.h"
#import "Util_UI.h"

@implementation PPCGroupCell
@synthesize statueImg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
//        [self.contentView addSubview:status];
        // Initialization code
    }
    return self;
}
-(void)setValueForCellByData:(id ) data index:(int) index{
    if([data isKindOfClass:[NSArray class]]){
        NSArray *tempArray = (NSArray *)data;
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        
        if(index == 0){
            title.text = @"竞价房源";
            detail.text = [NSString stringWithFormat:@"房源数:%@套", [dic objectForKey:@"bidPlanPropNum"]];
        } else if (index == [data count] - 1){//未推广
            title.text = @"未推广房源";
            detail.text = [NSString stringWithFormat:@"房源数:%@套", [dic objectForKey:@"unRecommendPropNum"]];

        }else{//定价
            title.text = @"定价房源";
            detail.text = [NSString stringWithFormat:@"%@ 房源数:%@套", [dic objectForKey:@"fixPlanName"], [dic objectForKey:@"fixPlanPropNum"]];
            if([[dic objectForKey:@"fixPlanState"] intValue] == 1){
                statueImg.frame = CGRectMake(260, 25, 24, 12);
                [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_woking@2x.png"]];
            }else{
                statueImg.frame = CGRectMake(260, 25, 24, 12);
                [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_stop@2x.png"]];
            }
        }
    }
}

-(void)setFixedGroupValueForCellByData:(id ) data index:(int) index{
    if([data isKindOfClass:[NSArray class]]){
        NSArray *tempArray = (NSArray *)data;
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        
            title.text = @"定价房源";
            detail.text = [NSString stringWithFormat:@"%@ 房源数:%@套", [dic objectForKey:@"fixPlanName"], [dic objectForKey:@"fixPlanPropNum"]];
            if([[dic objectForKey:@"fixPlanState"] intValue] == 1){
                statueImg.frame = CGRectMake(260, 25, 24, 12);
                [statueImg setImage:[UIImage imageNamed:@"anjuke_icon09_woking@2x.png"]];
            }else if ([[dic objectForKey:@"pricPlanStateDesc"] isEqualToString:@"未推广"]){
                statueImg.frame = CGRectMake(260, 25, 12, 12);
                [statueImg setImage:[UIImage imageNamed:@"anjuke_icon08_attention@2x.png"]];
            }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
