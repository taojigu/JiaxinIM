//
//  JXGroup.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseModel.h"
#import "JXEnumDefs.h"

@class JXGroupMember;

@interface JXGroup : JXBaseModel

/*!
 @class
 @brief 群组ID （群组的唯一标识）
 */
@property(nonatomic, copy) NSString *groupId;

/*!
 @class
 @brief 群标题
 */
@property(nonatomic, copy) NSString *subject;

/*!
 @class
 @brief 群描述
 */
@property(nonatomic, copy) NSString *desc;

/*!
 @class
 @brief 群昵称
 */
@property(nonatomic, copy) NSString *nickname;

/*!
 @class
 @brief 群评论
 */
@property(nonatomic, copy) NSString *remark;

/*!
 @class
 @brief 群主
 */
@property(nonatomic, copy) NSString *owner;

/*!
 @class
 @brief 群组最后消息发生时间戳
 */
@property(nonatomic, copy) NSString *timestamp;

/*!
 @class
 @brief 是否可以加入该群  （yes 为可以， no 为不可以）
 */
@property(nonatomic, assign) BOOL isJoined;

/*!
 @class
 @brief 是否为公开群     （yes 为公开群， no 为不公开群）
 */
@property(nonatomic, assign) BOOL isPublic;

/*!
 @class
 @brief 是否需要核对信息  （yes 为需要， no 为不需要）
 */
@property(nonatomic, assign) BOOL isVerifyRequired;

/*!
 @class
 @brief 是否可以邀请成员  （yes 为可以， no 为不可以）
 */
@property(nonatomic, assign) BOOL canInvite;

/*!
 @class
 @brief 是否可以修改群标题  （yes 为可以， no 为不可以）
 */
@property(nonatomic, assign) BOOL canChangeSubject;

/*!
 @class
 @brief 最大的成员数
 */
@property(nonatomic, assign) NSInteger maxMembers;

/*!
 @class
 @brief 用户的数量
 */
@property(nonatomic, assign) NSInteger userNumber;

/*!
 @class
 @brief 群聊策略
 */
@property(nonatomic, assign) JXGroupPolicy policy;

/*!
 @method
 @brief 通过 群成员的用户名获得群主成员
 @param username    群成员的用户名
 @discussion
 @result JXGroupMember  群成员对象
 */
- (JXGroupMember *)memberWithUsername:(NSString *)username;

@end
