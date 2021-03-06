//
//  AJKSaveMessModel.h
//  AnjukeBroker_New
//
//  Created by anjuke on 14-5-25.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AJKSaveMessModel : NSObject

@property (nonatomic, strong)NSString  *profid;//房源id
@property (nonatomic, strong)NSString  *st;//编辑时间
@property (nonatomic, strong)NSDate    *stDa;//编辑时间
@property (nonatomic, assign)NSInteger sna;//室内图相册张数
@property (nonatomic, assign)NSInteger snc;//室内图拍照张数
@property (nonatomic, assign)NSInteger fxa;//户型图相册张数
@property (nonatomic, assign)NSInteger fxo;//户型图在线选择樟树
@property (nonatomic, strong, readonly)NSString  *pd;//描述的文字

- (NSString *)objToJson;
- (NSDictionary *)objectToDict;
- (NSString *)setPdString:(NSArray *)arr;
- (NSString *)setPdString:(NSArray *)arr idArr:(NSArray *)idArr;
@end
