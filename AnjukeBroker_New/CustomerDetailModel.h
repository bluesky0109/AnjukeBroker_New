//
//  CustomerDetailModel.h
//  AnjukeBroker_New
//
//  Created by leozhu on 14-6-11.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "BaseModel.h"

@interface CustomerDetailModel : BaseModel

@property (nonatomic, copy) NSString* app;
@property (nonatomic, copy) NSString* i;
@property (nonatomic, copy) NSString* macid;
@property (nonatomic, copy) NSString* udid2;
@property (nonatomic, copy) NSString* device_id; //设备号
@property (nonatomic, copy) NSString* user_name; //用户名称
@property (nonatomic, copy) NSString* user_portrait; //用户头像路径
@property (nonatomic, copy) NSString* comm_preference; //偏好小区
@property (nonatomic, copy) NSString* house_type_preference; //偏好户型
@property (nonatomic, copy) NSString* price_preference; //偏好价格
@property (nonatomic, copy) NSString* view_prop_num; //浏览房源数量
@property (nonatomic, strong) NSMutableArray* view_prop_info; //浏览小区数组
@property (nonatomic, copy) NSString* status; //用户相对于经纪人状态

@property (nonatomic, assign) int lineHeight; //记录偏好小区label的高度

@end
