//
//  JXChatManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXConversation.h"

@protocol JXChatManagerDelegate<JXBaseDelegate>

@optional

/*!
 @method
 @brief 插入消息到Conversation的回调
 @discussion
 @param message   消息对象(包括from, to, body列表等信息)
 @result
 */
- (void)didInsertMessage:(JXMessage *)message;

/*!
 @method
 @brief 接收消息的回调
 @discussion
 @param message   消息对象(包括from, to, body列表等信息)
 @result
 */
- (void)didReceiveMessage:(JXMessage *)message;

/*!
 @method
 @brief 删除消息的回调
 @discussion
 @param message   消息对象(包括from, to, body列表等信息)
 @result
 */
- (void)didRemoveMessage:(JXMessage *)message;

/*!
 @method
 @brief 消息状态改变的回调
 @discussion
 @param message   消息对象(包括from, to, body列表等信息)
 @result
 */
- (void)didMessageStatusChanged:(JXMessage *)message;

/*!
 @method
 @brief 消息上传状态改变的回调
 @discussion
 @param message   消息对象(包括from, to, body列表等信息)
 @param progress  上传的进度
 @result
 */
- (void)didMessageUploadStatusChanged:(JXMessage *)message progress:(float)progress;

/*!
 @method
 @brief 创建新会话的回调
 @discussion
 @param session   会话对象
 @result
 */
- (void)newConversation:(JXConversation *)session;

/*!
 @method
 @brief 更新会话列表的回调
 @discussion
 @param conversationList   会话列表
 @result
 */
- (void)didUpdateConversationList:(NSArray *)conversationList;

@end
