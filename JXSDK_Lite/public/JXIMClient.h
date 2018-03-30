//
//  JXIMClient.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "ICallManager.h"
#import "IChatManager.h"
#import "IChatRoomManager.h"
#import "IConferenceManager.h"
#import "IContactManager.h"
#import "IGroupManager.h"
#import "ILoginManager.h"
#import "IMCSManager.h"
#import "JXError.h"
#import "JXAppConfig.h"

@interface JXIMClient : NSObject

/*!
 @class
 @brief loginManager的代理
 */
@property(nonatomic, strong) id<ILoginManager> loginManager;

/*!
 @class
 @brief contactManager的代理
 */
@property(nonatomic, strong) id<IContactManager> contactManager;

/*!
 @class
 @brief chatManager的代理
 */
@property(nonatomic, strong) id<IChatManager> chatManager;

/*!
 @class
 @brief groupManager的代理
 */
@property(nonatomic, strong) id<IGroupManager> groupManager;

/*!
 @class
 @brief callManager的代理
 */
@property(nonatomic, strong) id<ICallManager> callManager;

/*!
 @class
 @brief mcsManager的代理
 */
@property(nonatomic, strong) id<IMCSManager> mcsManager;

/*!
 @class
 @brief chatRoomManager的代理
 */
@property(nonatomic, strong) id<IChatRoomManager> chatRoomManager;

/*!
 @class
 @brief conferenceManager的代理
 */
@property(nonatomic, strong) id<IConferenceManager> conferenceManager;

/*!
 @method
 @brief 初始化单例对象
 @discussion
 @result JXIMClient JXIMClient对象
 */
+ (JXIMClient *)sharedInstance;

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

/**
 是否按渠道号显示不同历史消息

 @param enable 默认为NO
 */
- (void)enableMessageGroupByChannelNo:(BOOL)enable;

/*!
 @method
 @brief 上传用户反馈的内容
 @discussion
 @param title    反馈的标题
 @param contentText    反馈的内容
 @param callback    没有返回值，参数为JXError的回调
 @result
 */
- (void)reportBugWithTitle:(NSString *)title
                   content:(NSString *)contentText
                  callback:(void (^)(JXError *error))callback;

/*!
 @method
 @brief 获得版本信息
 @discussion
 @param callback    没有返回值，参数为error和responseStr的回调
 @result
 */
- (void)getVersionInfocallback:(void (^)(id res, NSError *error))callback;

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
