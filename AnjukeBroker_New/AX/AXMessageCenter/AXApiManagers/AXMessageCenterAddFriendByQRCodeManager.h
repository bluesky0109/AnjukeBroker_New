//
//  AXMessageCenterAddFriendByQRCodeManager.h
//  Anjuke2
//
//  Created by 杨 志豪 on 14-3-11.
//  Copyright (c) 2014年 anjuke inc. All rights reserved.
//

#import "RTAPIBaseManager.h"

@interface AXMessageCenterAddFriendByQRCodeManager : RTAPIBaseManager<RTAPIManagerValidator,RTAPIManagerParamSourceDelegate>
@property (nonatomic,strong) NSDictionary *apiParams;
@end