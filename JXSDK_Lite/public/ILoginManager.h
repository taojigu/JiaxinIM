//
//  JXLoginManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"

@protocol ILoginManager<IBaseManager>

/*!
 @class
 @brief 用户名
 */
@property(nonatomic, readonly) NSString *username;

/*!
 @method
 @brief 通过用户名，密码来注册账号
 @discussion
 @param userName    用户名
 @param password    密码
 @param callback    没有返回值，参数为JXError的回调
 @result
 */
- (void)registerWithUserName:(NSString *)userName
                    password:(NSString *)password
                    callback:(void (^)(JXError *error))callback;

/*!
 @method
 @brief 通过config, customId
 @discussion
 @param config      config
 @param callback    没有返回值，参数为JXError的回调
 @result
 */
- (void)registerWithConfig:(NSDictionary *)config
                  callback:(void (^)(JXError *error, NSString *token))callback;

/*!
 @method
 @brief 通过simple token
 @result
 */
- (void)loginWithShortToken:(NSString *)token;

/*!
 @method
 @brief 通过用户名，密码来登录
 @discussion
 @param userName    用户名
 @param password    密码
 @result
 */
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password;

/*!
 @method
 @brief 通过用户名，token来登录
 @discussion
 @param userName    用户名
 @param token    token
 @result
 */
- (void)loginWithUserName:(NSString *)userName token:(NSString *)token customerId:(NSString *)customerId;

/*!
 @method
 @brief 坐席或管理员通过email，密码来登录, sdk将自动获取appKey
 @discussion
 @param email       用户名
 @param password    密码
 @result
 */
- (void)loginWithEmail:(NSString *)email password:(NSString *)password;

/*!
 @method
 @brief 登出
 @discussion
 @result
 */
- (void)logout;

@end
