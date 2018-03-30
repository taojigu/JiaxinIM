//
//  JXIMClient.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IMCSManager.h"
#import "ILoginManager.h"
#import "IChatManager.h"

#import "JXError.h"
#import "JXAppConfig.h"

@interface JXMCSClient : NSObject

/*!
 @class
 @brief loginManager的代理
 */
@property(nonatomic, strong) id<ILoginManager> loginManager;

/*!
 @class
 @brief chatManager的代理
 */
@property(nonatomic, strong) id<IChatManager> chatManager;

/*!
 @class
 @brief mcsManager的代理
 */
@property(nonatomic, strong) id<IMCSManager> mcsManager;

/*!
 @method
 @brief 初始化单例对象
 @discussion
 @result JXIMClient JXIMClient对象
 */
+ (JXMCSClient *)sharedInstance;

/*!
 @method
 @brief 添加监听
 @discussion
 @param delegate    遵循JXClientDelegate协议的对象
 @result
 */
- (void)addDelegate:(id<JXClientDelegate>)delegate;

/*!
 @method
 @brief 移除监听
 @discussion
 @param delegate    遵循JXClientDelegate协议的对象
 @result
 */
- (void)removeDelegate:(id<JXClientDelegate>)delegate;

/*!
 @method
 @brief 用APPkey来注册SDK
 @discussion
 @param key    在佳信官网上注册的APPkey
 @result JXError 错误信息
 */
- (JXError *)registerSDKWithAppKey:(NSString *)key;

/*!
 @method
 @brief 清除用户数据缓存
 @discussion
 @param contact
 @result
 */
- (void)clearCaches:(void (^)(BOOL isCompleted))finishedBlcok;

/*!
 @method
 @brief 绑定deviceToken
 @discussion 在AppDelegate的application:didRegisterForRemoteNotificationsWithDeviceToken:方法中调用
 @param deviceToken
 @result
 */
- (void)bindDeviceToken:(NSData *)deviceToken;

/*!
 @method
 @brief app delegate
 @discussion
 @param contact
 @result
 */
- (void)appDidEnterBackground:(NSNotification *)notify;
- (void)appWillEnterForeground:(NSNotification *)notify;
- (void)appDidFinishLaunching:(NSNotification *)notify;
- (void)appDidBecomeActive:(NSNotification *)notify;
- (void)appWillResignActive:(NSNotification *)notify;
- (void)appDidReceiveMemoryWarning:(NSNotification *)notify;
- (void)appWillTerminate:(NSNotification *)notify;
- (void)appProtectedDataWillBecomeUnavailable:(NSNotification *)notify;
- (void)appProtectedDataDidBecomeAvailable:(NSNotification *)notify;

@end
