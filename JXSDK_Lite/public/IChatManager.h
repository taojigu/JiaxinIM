//
//  JXChatManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"

@protocol IChatManager<IBaseManager>

/*!
 @class
 @brief 是否允许发送已读回执 （yes 为允许， no 为不允许）
 */
@property(atomic) BOOL sendReadReceipt;

/*!
 @class
 @brief 是否需要已读回执 （yes 为需要， no 为不需要）
 */
@property(atomic) BOOL needReadReceipt;

/*!
 @class
 @brief 是否需要送达回执 （yes 为需要， no 为不需要）
 */
@property(atomic) BOOL needDeliveryReceipt;

/*!
 @method
 @brief 通过名称和聊天类型来获得会话对象
 @discussion
 @param chatter  群聊/聊天室时，群聊/聊天室名称，单聊时为用户名
 @param type     聊天类型
 @result JXConversation 会话对象
 */
- (JXConversation *)conversationForChatter:(NSString *)chatter andType:(JXChatType)type;

/*!
 @method
 @brief 获得会话列表
 @discussion
 @result NSArray 会话列表
 */
- (NSArray *)sessionList;

/*!
 @method
 @brief 添加消息
 @discussion
 @param message  消息对象
 @result
 */
- (void)addMessage:(JXMessage *)message;

/*!
 @method
 @brief 发送消息
 @discussion
 @param message  消息对象
 @result
 */
- (void)sendMessage:(JXMessage *)message;

/*!
 @method
 @brief 销毁会话
 @discussion
 @param session  会话对象
 @result
 */
- (void)destoryConversation:(JXConversation *)session;

/*!
 @method
 @brief 下载附件
 @discussion
 @param message  消息对象
 @param callback  没有返回值，参数为result和JXError的回调
 @param progressBlock  没有返回值，参数为progress的下载进度回调
 @result
 */
- (void)downloadAttachmentForMessage:(JXMessage *)message
                              result:(void (^)(id result, JXError *error))callback
                            progress:(void (^)(float progress))progressBlock;

@end
