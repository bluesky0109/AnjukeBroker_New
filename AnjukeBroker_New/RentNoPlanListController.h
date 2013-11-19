//
//  RantNoPlanListController.h
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 11/4/13.
//  Copyright (c) 2013 Wu sicong. All rights reserved.
//

#import "BaseNoPlanController.h"
#import "SaleNoPlanListCell.h"
#import "FixedObject.h"

@interface RentNoPlanListController : BaseNoPlanController <UIActionSheetDelegate, UIAlertViewDelegate, CheckmarkBtnClickDelegate>
@property (strong,nonatomic) NSDictionary *tempDic;
@property (strong, nonatomic) FixedObject *fixedObj;
@end
