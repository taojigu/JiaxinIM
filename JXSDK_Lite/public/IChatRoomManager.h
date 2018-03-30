//
//  IChatRoomManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"

@protocol IChatRoomManager<IBaseManager>

/*!
 @method
 @brief 通过聊天室ID来获得聊天室对象
 @discussion
 @param chatroomId  聊天室ID （聊天室的唯一标识）
 @result JXChatroom 聊天室对象
 */
- (JXChatroom *)chatRoomForId:(NSString *)chatroomId;


/*!
 @method
 @brief  查询聊天室
 @discussion
 @param chatRoomName  聊天室名字 (为空时就是查询全部聊天室)
 @param pageNum   页数
 @param count     数量
 @param success    没有返回值，参数为responseObject成功的回调
 @param failure    没有返回值，参数为JXError失败的回调
 @result
 */
- (void)queryChatRoomsName:(NSString *)chatRoomName
                pageNumber:(NSUInteger)pageNum
                     count:(NSUInteger)count
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(JXError *error))failure;

/*!
 @method
 @brief  加入聊天室
 @discussion
 @param roomId  聊天室Id
 @param nickName   进入聊天室的昵称
  @result
 */
- (void)joinChatroom:(NSString *)roomId;

/*!
 @method
 @brief  离开聊天室
 @discussion
 @param roomId  聊天室Id
 @result
 */
- (void)leaveChatroom:(NSString *)roomId;

@end
