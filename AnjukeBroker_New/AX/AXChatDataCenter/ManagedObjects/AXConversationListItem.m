//
//  AXConversationListItem.m
//  Anjuke2
//
//  Created by casa on 14-2-24.
//  Copyright (c) 2014年 anjuke inc. All rights reserved.
//

#import "AXConversationListItem.h"


@implementation AXConversationListItem

@dynamic count;
@dynamic friendUid;
@dynamic lastUpdateTime;
@dynamic messageTip;
@dynamic messageType;
@dynamic presentName;
@dynamic iconUrl;
@dynamic lastMsgIdentifier;
@dynamic iconPath;
@dynamic isIconDownloaded;
@dynamic messageStatus;

- (AXMappedConversationListItem *)convertToMappedObject
{
    AXMappedConversationListItem *mappedConversationListItem = [[AXMappedConversationListItem alloc] init];
    mappedConversationListItem.count = self.count;
    mappedConversationListItem.friendUid = self.friendUid;
    mappedConversationListItem.iconPath = self.iconPath;
    mappedConversationListItem.iconUrl = self.iconUrl;
    mappedConversationListItem.isIconDownloaded = self.isIconDownloaded;
    mappedConversationListItem.lastMsgIdentifier = self.lastMsgIdentifier;
    mappedConversationListItem.lastUpdateTime = self.lastUpdateTime;
    mappedConversationListItem.messageTip = self.messageTip;
    mappedConversationListItem.messageType = self.messageType;
    mappedConversationListItem.presentName = self.presentName;
    mappedConversationListItem.messageStatus = self.messageStatus;
    return mappedConversationListItem;
}

- (void)assignPropertiesFromMappedObject:(AXMappedConversationListItem *)mappedConversationListItem
{
    self.count = mappedConversationListItem.count;
    self.friendUid = mappedConversationListItem.friendUid;
    self.iconPath = mappedConversationListItem.iconPath;
    self.iconUrl = mappedConversationListItem.iconUrl;
    self.isIconDownloaded = mappedConversationListItem.isIconDownloaded;
    self.lastMsgIdentifier = mappedConversationListItem.lastMsgIdentifier;
    self.lastUpdateTime = mappedConversationListItem.lastUpdateTime;
    self.messageTip = mappedConversationListItem.messageTip;
    self.messageType = mappedConversationListItem.messageType;
    self.presentName = mappedConversationListItem.presentName;
    self.messageStatus = mappedConversationListItem.messageStatus;
}

@end