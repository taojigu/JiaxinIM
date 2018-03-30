//
//  JXChatroomManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXChatroom.h"

@protocol JXChatroomManagerDelegate<JXBaseDelegate>

@optional

/*!
 @method
 @brief  已经加入聊天室的回调
 @discussion
 @param roomId    聊天室ID
 @result
 */
- (void)didJoinChatroom:(NSString *)roomId withError:(JXError *)error;

/*!
 @method
 @brief  已经离开聊天室的回调
 @discussion
 @param roomId    聊天室ID
 @result
 */
- (void)didLeaveChatroom:(NSString *)roomId;

/*!
 @method
 @brief  有人加入聊天室的回调
 @discussion
 @param useName    用户名
 @result
 */
- (void)peopleJoinChatroom:(NSString *)useName;

/*!
 @method
 @brief  有人离开聊天室的回调
 @discussion
 @param useName    用户名
 @result
 */
- (void)peopleLeaveChatroom:(NSString *)useName;

/*!
 @method
 @brief  聊天室被摧毁的回调
 @discussion
 @param roomId    聊天室ID
 @result
 */
- (void)chatroomDidDestory:(NSString *)roomId;

@end
