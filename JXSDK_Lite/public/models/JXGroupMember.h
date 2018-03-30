//
//  JXGroupMember.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseModel.h"
#import "JXEnumDefs.h"

@interface JXGroupMember : JXBaseModel

/*!
 @class
 @brief 群组ID (群的唯一标识)
 */
@property(nonatomic, copy) NSString *groupId;

/*!
 @class
 @brief 群成员的用户名
 */
@property(nonatomic, copy) NSString *username;

/*!
 @class
 @brief 群成员的昵称
 */
@property(nonatomic, copy) NSString *nickname;

/*!
 @class
 @brief 群成员在群组中的角色
 */
@property(nonatomic, assign) JXGroupRole role;

/*!
 @class
 @brief 时间
 */
@property(nonatomic, copy) NSString *date;

@end
