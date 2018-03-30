//
//  JXContact.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseModel.h"

@interface JXContact : JXBaseModel

/*!
 @class
 @brief 用户名
 */
@property(nonnull, nonatomic, copy) NSString *username;

/*!
 @class
 @brief 昵称
 */
@property(nullable, nonatomic, copy) NSString *nickname;

/*!
 @class
 @brief 昵称
 */
@property (nullable, nonatomic, copy) NSString *contactIconInfo;

/*!
 @method
 @brief 对象方法初始化一个联系人对象
 @discussion
 @param userName     用户名
 @result instancetype      对象本身
 */
- (nullable instancetype)initWithUserName:(nonnull NSString *)userName;

@end
