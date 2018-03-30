//
//  JXContactManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXContact.h"

@protocol JXContactManagerDelegate<JXBaseDelegate>

@optional

/*!
 @method
 @brief 接收到好友请求通知的回调
 @discussion
 @param contact 好友对象
 @param message 收到好友请求时的say hello消息
 @result
 */
- (void)didReceiveAddFriendRequest:(JXContact *)contact message:(NSString *)message;

/*!
 @method
 @brief 主动发送添加好友请求成功的回调
 @discussion
 @param contact 好友对象
 @param message 收到好友请求时的say hello消息
 @result
 */
- (void)didSendAddFriendRequest:(JXContact *)contact message:(NSString *)message;

/*!
 @method
 @brief 主动发送删除好友请求成功的回调
 @discussion
 @param contact 好友对象
 @result
 */
- (void)didSendRemoveFriendRequest:(JXContact *)contact;

/*!
 @method
 @brief 接受好友请求成功的回调
 @discussion
 @param contact 好友对象
 @result
 */
- (void)didAcceptContactSucceed:(JXContact *)contact;

/*!
 @method
 @brief 拒绝好友请求成功的回调
 @discussion
 @param contact 好友对象
 @result
 */
- (void)didRejectContactSucceed:(JXContact *)contact;

/*!
 @method
 @brief 好友请求被接受的回调
 @discussion
 @param contact 好友对象
 @result
 */
- (void)didAcceptedByContact:(JXContact *)contact;

/*!
 @method
 @brief 好友请求被拒绝的回调
 @discussion
 @param contact 好友对象
 @result
 */
- (void)didRejectedByContact:(JXContact *)contact;

/*!
 @method
 @brief  已经删除好友的回调
 @discussion
 @param contact 好友对象
 @result
 */
- (void)didRemovedContact:(JXContact *)contact;

/*!
 @method
 @brief  已经被删除好友的回调
 @discussion
 @param contact 好友对象
 @result
 */
- (void)didRemovedByContact:(JXContact *)contact;

/*!
 @method
 @brief 通讯录信息发生变化时的回调
 @discussion
 @param contactList    好友信息列表
 @param changedBuddies 修改了的用户列表
 @param isAdd          (YES为新添加好友, NO为删除好友)
 @result
 */
- (void)didUpdateContactList:(NSArray *)contactList
              changedBuddies:(NSArray *)changedFriends
                       isAdd:(BOOL)isAdd;

/*!
 @method
 @brief 好友分组信息发生变化时的回调
 @discussion
 @param contactGroupList 好友分组信息列表
 @result
 */
- (void)didUpdateBuddyGroupList:(NSArray *)contactGroupList;

/*!
 @method
 @brief 好友在线状态改变的回调
 @discussion
 @param isOnline 好友是否在线，(yes为在线，no为不在线)
 @param username 修改了状态的用户名
 @result
 */
- (void)didChangedOnlineStatus:(BOOL)isOnline forBuddy:(NSString *)username;

/*!
 @method
 @brief 搜索到相关用户的回调
 @discussion
 @param userArray 匹配到的相关用户列表
 @result
 */
- (void)didGetSearchResult:(NSArray *)userArray;

#pragma mark - block

/*!
 @method
 @brief 好友黑名单有更新时的回调
 @discussion
 @param blockedList 被加入黑名单的好友的列表
 @result
 */
- (void)didUpdateBlockedList:(NSArray *)blockedList;

/*!
 @method
 @brief 将好友加到黑名单完成后的回调
 @discussion
 @param username    加入黑名单的好友
 @param pError      错误信息
 @result
 */
- (void)didBlockBuddy:(NSString *)username error:(JXError *)pError;

/*!
 @method
 @brief 将好友移出黑名单完成后的回调
 @discussion
 @param username    移出黑名单的好友
 @param pError      错误信息
 @result
 */
- (void)didUnblockBuddy:(NSString *)username error:(JXError *)pError;

@end
