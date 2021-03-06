//
//  NoPlanListCell.m
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 10/28/13.
//  Copyright (c) 2013 Wu sicong. All rights reserved.
//

#import "BaseNoPlanListCell.h"
#import "Util_UI.h"

@implementation BaseNoPlanListCell
@synthesize title;
@synthesize detail;
@synthesize price;
@synthesize mutableSelect;
@synthesize proIcon;
@synthesize backView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(48, 0, 270, self.contentView.frame.size.height)];
        self.backView.backgroundColor = [UIColor clearColor];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.numberOfLines = 0;
//        self.title.lineBreakMode = NSLineBreakByWordWrapping;
        self.title.textColor = SYSTEM_BLACK;
        self.title.font = [UIFont systemFontOfSize:14];
        
        self.detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 270, 20)];
        self.detail.textColor = [Util_UI colorWithHexString:@"#666666"];
        self.detail.font = [UIFont systemFontOfSize:12];
        self.detail.backgroundColor = [UIColor clearColor];
        
        self.proIcon = [[UIImageView alloc] init];
//        self.proIcon.frame = CGRectMake(280, self.title.frame.origin.y + 2, 22, 14);
        
        self.price = [[UILabel alloc] initWithFrame:CGRectMake(210, 30, 150, 20)];
        self.price.textColor = [UIColor grayColor];
        self.price.font = [UIFont systemFontOfSize:12];
        
        [self.backView addSubview:self.title];
        [self.backView addSubview:self.detail];
        [self.contentView addSubview:self.proIcon];
        [self.contentView addSubview:self.backView];
        // Initialization code
    }
    return self;
}

- (BOOL)configureCell:(id)dataModel withIndex:(int)index {
    [super configureCell:dataModel withIndex:index];
    if([dataModel isKindOfClass:[BasePropertyObject class]]){
        BasePropertyObject *tempProperty = (BasePropertyObject *)dataModel;
        [self setDetailLableValue:tempProperty];
        self.title.text = tempProperty.title;
//        CGSize size = CGSizeMake(250, 40);
        CGSize si = [Util_UI sizeOfString:tempProperty.title maxWidth:250 withFontSize:14];//[tempProperty.title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        
        self.title.frame = CGRectMake(0, 8, si.width, si.height);
        self.proIcon.frame = CGRectMake(290, self.title.frame.origin.y + 2, 22, 14);
        self.detail.frame = CGRectMake(0, self.title.frame.size.height + 15, 270, 20);
        [self setProIconWithPro:tempProperty];
        return YES;
    }

    return NO;
}
-(void)setDetailLableValue:(BasePropertyObject *) pro{
    NSString *tempStr = [NSString stringWithFormat:@"%@  %@室%@厅  %@平 %@%@", pro.communityName, pro.roomNum, pro.hallNum, pro.area, pro.price, pro.priceUnit];
    self.detail.text = tempStr;
}
- (void)setProIconWithPro:(BasePropertyObject *) pro{
    if([pro.isMoreImg isEqualToString:@"1"]&&[pro.isVisible isEqualToString:@"1"]){
    self.proIcon.image = [UIImage imageNamed:@"anjuke_icon_mutableimg.png"];
    }else if([pro.isVisible isEqualToString:@"0"]){
    self.proIcon.image = [UIImage imageNamed:@"anjuke_icon_violat.png"];
    }else{
   // anjuke_icon_draft.png
    self.proIcon.image = nil;
    }

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
