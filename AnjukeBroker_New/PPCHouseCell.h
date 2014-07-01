//
//  PPCHouseCell.h
//  AnjukeBroker_New
//
//  Created by xiazer on 14-7-1.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import "RTListCell.h"
#import "SWTableViewCell.h"
#import "BrokerLineView.h"

@interface PPCHouseCell : SWTableViewCell

@property (strong, nonatomic) BrokerLineView *lineView;


- (BOOL)configureCell:(id)dataModel withIndex:(int)index;
- (void)showBottonLineWithCellHeight:(CGFloat)cellH andOffsetX:(CGFloat)offsetX;

@end