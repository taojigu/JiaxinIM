//
//  JXMCSUserManager.h
//

#import "JXRestUtil.h"
#import "JXMcsEvaluation.h"
#import "JXWorkgroup.h"
#import "JXError.h"
#import "JXSDKHelper.h"
#import "JXMcsChatConfig.h"
#import <Foundation/Foundation.h>

#define kNotification_loginSucess @"KNotification_loginSucess"
#define kNotification_logoutUser @"kNotification_logoutUser"
#define kNotification_disConnected @"kNotification_disConnected"

typedef void (^JXUserActiveResponseBlock)(BOOL success, id response);

@interface JXMCSUserManager : NSObject

+ (instancetype)sharedInstance;

/**
 评价模型
 */
- (JXMcsEvaluation *)evaluation;

/**
 快捷提问问题
 */
- (NSArray *)quickQuestions;

/**
 是否已经登陆
 */
- (BOOL)isLogin;

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

/**
 @param loginResponse
 */
- (void)loginWithCallback:(JXUserActiveResponseBlock)loginResponse;

/**
 通过appkey随机生成账号登陆(demo随机生成账号，方便测试，可能不符合企业业务需求，不建议使用)
 @param appKey
 @param loginResponse
 */
- (void)loginWithAppKey:(NSString *)appKey responseObject:(JXUserActiveResponseBlock)loginResponse;

/**
 通过token及customerId登陆
 */
- (void)loginWithUserName:(NSString *)userName
                    token:(NSString *)token
               customerId:(NSString *)customerId
           responseObject:(JXUserActiveResponseBlock)loginResponse;

/**
 退出登录
 */
- (void)logoutWithResponseBlock:(JXUserActiveResponseBlock)logoutResponse;

/**
 请求服务客服服务
 
 @param navC 当前控制器的navigationController,用于push界面
 */
- (void)requestCSForUI:(UINavigationController *)navC;

- (void)requestCSForUI:(UINavigationController *)navC witConfig:(JXMcsChatConfig *)config;

@property(nonatomic, strong, readonly) JXMcsChatConfig *config;
@property(nonatomic, strong, readonly) UIImage *originNavImage;
@property(nonatomic, strong, readonly) NSDictionary *originNavAttributes;

/**
 请求服务客服服务
 
 @param navC 当前控制器的navigationController,用于push界面
 @param indexPath
 */
- (void)requestCSForUI:(UINavigationController *)navC
             indexPath:(NSInteger)indexPath DEPRECATED("use requestCSForUI:");

/**
 加载离线消息界面

 @param vc 当前控制器
 @param workgroup 当前技能组
 */
- (void)leaveMessageOnlineForUI:(UIViewController *)vc workgroup:(JXWorkgroup *)workgroup;

/**
 消息箱未读消息数
 */
@property(nonatomic, assign, readonly) NSInteger unreadMessageCount;

/**
 客服是否在线
 */
@property(nonatomic, assign, readwrite) BOOL isInService;

/**
 设置所有离线消息已读
 */
- (BOOL)setAllMessageRead;

#pragma mark - rest API

+ (void)GETWithApi:(NSString *)api
              params:(NSDictionary *)params
        withCallBack:(JXRestCallback)callback;

+ (void)POSTWithApi:(NSString *)api
              params:(NSDictionary *)params
        withCallBack:(JXRestCallback)callback;

+ (void)PUTWithApi:(NSString *)api
              params:(NSDictionary *)params
        withCallBack:(JXRestCallback)callback;

@end
