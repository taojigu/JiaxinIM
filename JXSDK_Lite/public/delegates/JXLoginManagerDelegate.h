//
//  JXLoginManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"

@protocol JXLoginManagerDelegate<JXBaseDelegate>

@optional

/*!
 @method
 @brief 登录成功的回调
 @discussion
 @result
 */
- (void)didLoginSuccess;

/*!
 @method
 @brief 登录失败的回调
 @param error     错误信息
 @discussion
 @result
 */
- (void)didLoginFailureWithError:(JXError *)error;

/*!
 @method
 @brief 成功退出登录的回调
 @discussion
 @result
 */
- (void)didLogoutSuccess;

/*!
 @method
 @brief 登录冲突的回调
 @discussion
 @param error     错误信息
 @result
 */
- (void)didForceLogoutWithError:(JXError *)error;

/*!
 @method
 @brief 连接状态更新
 @discussion
 @param error     错误信息
 @result
 */
- (void)didConnectionChanged:(BOOL)isConnected withError:(JXError *)error;

@end
