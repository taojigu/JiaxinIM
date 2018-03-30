//
//  JXConversation.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseModel.h"
#import "JXEnumDefs.h"
#import "JXMessage.h"

@interface JXConversation : JXBaseModel

/*!
 @class
 @brief 群聊/聊天室时，群聊/聊天室名称，单聊时为用户名
 */
@property(nonatomic, copy) NSString *chatter;

/*!
 @class
 @brief 获取会话标识
 */
@property(nonatomic, copy) NSString *subject;

/*!
 @class
 @brief 获取会话的聊天类型
 */
@property(nonatomic, assign) JXChatType type;

/*!
 @class
 @brief 会话是否置顶
 */
@property(atomic, assign) BOOL isTop;

/*!
 @class
 @brief 未读消息数量
 */
@property(nonatomic, readonly) NSInteger unReadCount;

/*!
 @method
 @brief 通过消息ID获得JXMessage对象
 @param mid    消息ID (消息的唯一标识)
 @discussion
 @result JXMessage  消息对象
 */
- (JXMessage *)messageForId:(NSString *)mid;

/*!
 @method
 @brief 判断消息是否存在缓存
 @param message    消息id
 @discussion
 @result BOOL 是否缓存
 */
- (BOOL)isCachedMessageId:(NSString *)messageId;

/*!
 @method
 @brief 获得最后一条消息
 @discussion
 @result JXMessage  消息对象
 */
- (JXMessage *)lastMessage;

/*!
 @method
 @brief 获得消息ID数组
 @discussion
 @result NSArray 消息ID的数组
 */
- (NSArray *)messageIds;

/*!
 @method
 @brief 重新设置未读消息数
 @discussion
 @result
 */
- (void)resetUnRead;

/*!
 @method
 @brief 删除消息
 @param message 消息对象
 @discussion
 @result
 */
- (void)deleteMessage:(JXMessage *)message;

@end
