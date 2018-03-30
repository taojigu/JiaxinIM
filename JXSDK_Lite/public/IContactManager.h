//
//  IContactManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"

@protocol IContactManager<IBaseManager>

/*!
 @class
 @brief 联系人列表
 */
@property(nonatomic, strong, readonly) NSArray *contactList;

/*!
 @class
 @brief 黑名单列表
 */
@property(nonatomic, strong, readonly) NSArray *blockedList;

/*!
 @method
 @brief 通过用户名来获得联系人对象
 @discussion
 @param userName  用户名
 @result JXContact 联系人对象
 */
- (JXContact *)contactWithUserName:(NSString *)userName;

/*!
 @method
 @brief 添加联系人
 @discussion
 @param buddy  联系人对象
 @result
 */
- (void)addContact:(JXContact *)buddy;

/*!
 @method
 @brief 删除联系人
 @discussion
 @param buddy  联系人对象
 @result
 */
- (void)removeContact:(JXContact *)buddy;

/*!
 @method
 @brief 同意请求添加好友
 @discussion
 @param buddy  联系人对象
 @result
 */
- (void)acceptRequest:(JXContact *)buddy;

/*!
 @method
 @brief 拒绝请求添加好友
 @discussion
 @param buddy  联系人对象
 @result
 */
- (void)rejectRequest:(JXContact *)buddy;

/*!
 @method
 @brief 将好友加入黑名单
 @discussion
 @param buddy  联系人对象
 @result
 */
- (void)blockContact:(JXContact *)buddy;

/*!
 @method
 @brief 将好友移出黑名单
 @discussion
 @param buddy  联系人对象
 @result
 */
- (void)unblockContact:(JXContact *)buddy;

/*!
 @method
 @brief 通过用户名来搜索联系人
 @discussion
 @param userName  用户名
 @result
 */
- (void)searchUserByName:(NSString *)userName;

@end
