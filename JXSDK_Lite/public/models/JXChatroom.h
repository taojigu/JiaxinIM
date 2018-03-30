//
//  JXChatroom.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseModel.h"

@interface JXChatroom : JXBaseModel

/*!
 @class
 @brief 聊天室ID
 */
@property(nonatomic, copy) NSString *chatRoomId;

/*!
 @class
 @brief 聊天室名字
 */
@property(nonatomic, copy) NSString *subject;

/*!
 @class
 @brief 聊天室描述
 */
@property(nonatomic, copy) NSString *desc;

/*!
 @class
 @brief 错误的类型
 */
@property(nonatomic, assign) NSInteger maxMembers;

/*!
 @class
 @brief 聊天室的创建者
 */
@property(nonatomic, copy) NSString *owner;

/*!
 @class
 @brief 聊天室的创建时间
 */
@property(nonatomic, copy) NSString *createTime;

@end
