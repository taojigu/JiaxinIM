//
//  JXWorkgroup.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseModel.h"
#import "JXEnumDefs.h"

@interface JXWorkgroup : JXBaseModel

/*!
 @class
 @brief 技能组ID
 */
@property(nonatomic, copy) NSString *serviceID;

/*!
 @class
 @brief 技能组显示的名字
 */
@property(nonatomic, copy) NSString *displayName;

/*!
 @class
 @brief 技能组所在appname
 */
@property(nonatomic, copy) NSString *appName;

/*!
 @class
 @brief 当前客服昵称
 */
@property(nonatomic, readonly) NSString *serviceNickname;

/*!
 @class
 @brief 用户当前状态
 */
@property(nonatomic, readonly) JXMCSUserStatus status;

@end
