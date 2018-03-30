//
//  JXMCSUserManager.m
//

#import "JXMCSUserManager.h"

#import "JXMcsChatViewController.h"
#import "JXWebViewController.h"
#import "JXWorkgroupListController.h"
#import "JXLocalPushManager.h"

#import "JXIMClient+Helper.h"
#import "JXLocalizeHelper.h"

@interface JXMCSUserManager ()<JXClientDelegate>

@property(nonatomic, copy) JXUserActiveResponseBlock logoutResponseBlock;
@property(nonatomic, copy) JXUserActiveResponseBlock loginResponse;

@property(nonatomic, assign) BOOL isLogin;

// 评价列表显示
@property(nonatomic, strong) JXMcsEvaluation *evaluation;
// 快速提问列表
@property(nonatomic, strong) NSArray *quickQuestions;
// 未读消息数
@property(nonatomic, assign) NSInteger unreadMessageCount;

@end

@implementation JXMCSUserManager

+ (instancetype)sharedInstance {
    static JXMCSUserManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.isLogin = NO;
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [sClient.loginManager addDelegate:self];
        [sClient.mcsManager addDelegate:self];
        [sClient.chatManager addDelegate:[JXLocalPushManager sharedInstance]];
        _unreadMessageCount = -1;
        _config = [JXMcsChatConfig defaultConfig];
    }
    return self;
}

- (void)dealloc {
    [sClient.loginManager removeDelegate:self];
    [sClient.mcsManager removeDelegate:self];
    [sClient.chatManager removeDelegate:[JXLocalPushManager sharedInstance]];
}

#pragma mark - public

/**
 注册账号
 */
- (void)registerWithUserName:(NSString *)userName
                    password:(NSString *)password
                    callback:(void (^)(JXError *))callback {
    [sClient.loginManager registerWithUserName:userName password:password callback:callback];
}

- (void)loginWithCallback:(JXUserActiveResponseBlock)loginResponse {

    JXDebugAssert([sClient appKey]);

    NSDictionary *clientConfig = [JXIMClient clientConfig];
    NSString *cid = [clientConfig objectForKey:@"cid"];
    if ([cid length]) {
        if (![cid isEqualToString:[self mcsCid:[sClient appKey]]]) {
            [self clearAccount];
        }

        void (^regCallback)(JXError *, NSString *) = ^(JXError *error, NSString *token) {
            if (!error || error.errorCode == JXErrorTypeUsernameExist) {
                [self loginWithCid:cid responseObject:loginResponse];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [sJXHUD showMessage:[error getLocalDescription] duration:1.6];
            });
        };

        NSString *mcsAccount = [self mcsAccountForApp:[sClient appKey]];
        if (!mcsAccount.length) {
            [sClient.loginManager registerWithConfig:[JXIMClient clientConfig]
                                            callback:regCallback];
        } else {
            [self loginWithCid:cid responseObject:loginResponse];
        }
        return;
    }
    [self loginWithAppKey:[JXIMClient appkey] responseObject:loginResponse];
}

/**
 通过appkey随机生成账号登陆
 @param appKey
 @param loginResponse
 */
- (void)loginWithAppKey:(NSString *)appKey responseObject:(JXUserActiveResponseBlock)loginResponse {
    
   
    JXDebugAssert(appKey);
    
    self.loginResponse = loginResponse;
    JXError *error = [sClient registerSDKWithAppKey:appKey];
    if (error) {
        loginResponse(NO, error);
        return;
    }

    __block NSString *mcsAccount = [self mcsAccountForApp:appKey];
    __block NSString *mcsPassword;
    sClient.appKey = appKey;
    void (^regCallback)(JXError *) = ^(JXError *error) {
        if (error.errorCode == JXErrorTypeUsernameExist) {
            [self clearAccount];
            [self loginWithAppKey:appKey responseObject:loginResponse];
        } else if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.loginResponse) {
                    self.loginResponse(NO, error);
                }
            });
        } else {
            [self loginWithUserName:mcsAccount password:mcsPassword responseObject:loginResponse];
        }
    };
    // 账号没有缓存则重新生成
    if (!mcsAccount.length) {
        mcsAccount = [self generateMCSUsername];
        mcsPassword = [self mcsPasswordForAccount:mcsAccount];
        [self registerWithUserName:mcsAccount password:mcsPassword callback:regCallback];
    } else {
        mcsPassword = [self mcsPasswordForAccount:mcsAccount];
        [self loginWithUserName:mcsAccount password:mcsPassword responseObject:loginResponse];
    }
}

// 必须要注册appkey才能调用该方法
- (void)loginWithUserName:(NSString *)userName
                    token:(NSString *)token
               customerId:(NSString *)customerId
           responseObject:(JXUserActiveResponseBlock)loginResponse {
    self.loginResponse = loginResponse;
    self.isLogin = NO;
    [sClient.loginManager loginWithUserName:userName token:token customerId:customerId];
}

// 必须要注册appkey才能调用该方法
- (void)loginWithShortToken:(NSString *)token
           responseObject:(JXUserActiveResponseBlock)loginResponse {
    self.loginResponse = loginResponse;
    self.isLogin = NO;
    [sClient.loginManager loginWithShortToken:token];
}

- (void)loginWithCid:(NSString *)cid responseObject:(JXUserActiveResponseBlock)loginResponse {
    self.loginResponse = loginResponse;
    self.isLogin = NO;
    [sClient.loginManager loginWithShortToken:cid.jxmd5String];
}

// 必须要注册appkey才能调用该方法
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
           responseObject:(JXUserActiveResponseBlock)loginResponse {
    self.loginResponse = loginResponse;
    self.isLogin = NO;
    [sClient.loginManager loginWithUserName:userName password:password];
}

/**
 退出登录
 */
- (void)logoutWithResponseBlock:(JXUserActiveResponseBlock)logoutResponse {
    self.logoutResponseBlock = logoutResponse;
    [sJXHUD showMessageWithActivityIndicatorView:nil];
    [sClient.loginManager logout];
}

/**
 请求服务客服服务
 @param navC current navigationController
 */
- (void)requestCSForUI:(UINavigationController *)navC {
    [self requestCSForUI:navC witConfig:[JXMcsChatConfig defaultConfig]];
}

- (void)requestCSForUI:(UINavigationController *)navC witConfig:(JXMcsChatConfig *)config {
    _config = config;
    
    _originNavImage = [navC.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    _originNavAttributes = navC.navigationBar.titleTextAttributes;
    
    if ([JXIMClient clientConfig]) { // 在
        if ([JXIMClient clientConfig]) {
            [sClient.mcsManager updateVisitorInfo:[JXIMClient clientConfig]];
            [JXIMClient clearClientConfig];
        } else {
            [sClient.mcsManager updateVisitorInfo:[NSDictionary dictionary]];
        }
    }
    
    JXWorkgroup *service = [sClient.mcsManager activeService];
    UIViewController *nextVC;
    if (service && service.status != JXMCSUserStatusInRobot) {
        nextVC = [[JXMcsChatViewController alloc] initWithWorkgroup:service];
        nextVC.hidesBottomBarWhenPushed = YES;
        [navC pushViewController:nextVC animated:IOSVersion > 8.0];
    } else {
        [sJXHUD showMessageWithActivityIndicatorView:nil];
        __weak typeof(navC) weakNav = navC;
        [sClient.mcsManager fetchCustomServicesWithCallback:^(id responseObject, JXError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sJXHUD hideHUD];
                if (!error) {
                    NSArray *workgrouplist = responseObject;
                    if (workgrouplist.count == 1) {
                        JXMcsChatViewController *chatVC = [[JXMcsChatViewController alloc] initWithWorkgroup:workgrouplist.firstObject];
                        chatVC.hidesBottomBarWhenPushed = YES;
                        [weakNav pushViewController:chatVC animated:IOSVersion > 8.0];
                        return;
                    } else if (workgrouplist.count == 0) {
                        sJXHUDMes(JXUIString(@"no workgroup tips"), 1.f);
                        return;
                    }
                    JXWorkgroupListController *workListVC = [[JXWorkgroupListController alloc] init];
                    workListVC.workgroupList = workgrouplist;
                    workListVC.hidesBottomBarWhenPushed = YES;
                    [weakNav pushViewController:workListVC animated:IOSVersion > 8.0];
                } else {
                    sJXHUDMes(JXUIString(@"fail to get workgroup tips"), 1.f);
                }
            });
        }];
    }
}

// UI调用请求客服api
- (void)requestCSForUI:(UINavigationController *)navC indexPath:(NSInteger)indexPath {
    [self requestCSForUI:navC];
}

// UI加载在线留言
- (void)leaveMessageOnlineForUI:(UIViewController *)vc workgroup:(JXWorkgroup *)workgroup {
    NSString *urlString = [sClient.mcsManager leaveMessageURL:workgroup].absoluteString;
    NSString *lang = [[JXLocalizeHelper sharedLocalSystem] getLanguage];
    if ([lang length]) {
        urlString = [NSString stringWithFormat:@"%@&lang=%@", urlString, lang];
    }
    JXLog(@"load: %@", urlString);
    JXWebViewController *webVC = [[JXWebViewController alloc] init];
    webVC.title = JXUIString(@"leave message");
    webVC.netString = urlString;
    webVC.isModal = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
    if ([JXMCSUserManager sharedInstance].config.navColor) {
        UIImage *image = [UIImage imageWithColor:[JXMCSUserManager sharedInstance].config.navColor];
        [nav.navigationBar setBackgroundImage:image
                                forBarMetrics:(UIBarMetricsDefault)];
    }
    [nav.navigationBar setTitleTextAttributes:@{
                                              NSForegroundColorAttributeName :[JXMCSUserManager sharedInstance].config.navTitleColor,
                                              NSFontAttributeName : [JXMCSUserManager sharedInstance].config.navFont
                                               }];

    @try {
        [vc presentViewController:nav animated:YES completion:nil];
    } @catch (NSException *exception) {
        JXLog(@"%@", exception.reason);
    }
}

/**
 消息箱未读消息数
 */
- (NSInteger)unreadMessageCount {
    if (_unreadMessageCount >= 0) {
        return _unreadMessageCount;
    }
    NSString *api = [NSString stringWithFormat:@"visitor/msgbox/getUnreadCount?username=%@",
                                               [sClient.loginManager username]];
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    id response = nil;
    NSError *error = nil;
    [JXRestUtil sendSyncRequest:request withRes:&response error:&error];
    if (error || [response[@"code"] integerValue] != 200) {
        _unreadMessageCount = -1;
    } else {
        _unreadMessageCount = [response[@"receipt"][@"unreadCount"] integerValue];
    }
    return _unreadMessageCount;
}

/**
 设置所有离线消息已读
 */
- (BOOL)setAllMessageRead {
    if (self.unreadMessageCount == 0) return YES;

    NSDictionary *params = @{ @"username" : [sClient.loginManager username] };
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:@"visitor/msgbox/markAllAsRead"];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    id response = nil;
    NSError *error = nil;
    [JXRestUtil sendSyncRequest:request withRes:&response error:&error];
    if ([response[@"code"] integerValue] == 200) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        self.unreadMessageCount = 0;
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - rest API

+ (void)GETWithApi:(NSString *)api
              params:(NSDictionary *)params
        withCallBack:(JXRestCallback)callback {
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableString *urlString = [NSMutableString stringWithString:url.absoluteString];
    if (params && params.count > 0) {
        [urlString appendString:@"?"];
        for (NSString *key in params.allKeys) {
            [urlString appendString:[NSString stringWithFormat:@"%@=%@&", key, params[key]]];
        }
        [urlString deleteCharactersInRange:NSMakeRange(urlString.length - 1, 1)];
    }
    urlString = (NSMutableString *)[urlString
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    [JXRestUtil sendRequest:request withCallback:callback];
}

+ (void)POSTWithApi:(NSString *)api
              params:(NSDictionary *)params
        withCallBack:(JXRestCallback)callback {
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    if (params) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        request.HTTPBody = data;
    }
    request.HTTPMethod = @"POST";
    [JXRestUtil sendRequest:request withCallback:callback];
}

+ (void)PUTWithApi:(NSString *)api
              params:(NSDictionary *)params
        withCallBack:(JXRestCallback)callback {
    NSURL *url = [JXRestUtil getRestURLWithAppName:nil andApi:api];
    NSMutableURLRequest *request = [JXRestUtil requestWithURL:url];
    if (params) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        request.HTTPBody = data;
    }
    request.HTTPMethod = @"PUT";
    [JXRestUtil sendRequest:request withCallback:callback];
}

#pragma mark - account

/**
 清除账号
 */
- (void)clearAccount {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[sClient appKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 保存账号
 @param account 账号
 */
- (void)saveAccount:(NSString *)account {
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:[sClient appKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveCid:(NSString *)cid {
    if (![cid length]) {
        return;
    }
    NSString *cidKey = [NSString stringWithFormat:@"%@|cid", [sClient appKey]];
    [[NSUserDefaults standardUserDefaults] setObject:cid forKey:cidKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)mcsCid:(NSString *)appkey {
    NSString *cidKey = [NSString stringWithFormat:@"%@|cid", [sClient appKey]];
    return [[NSUserDefaults standardUserDefaults] objectForKey:cidKey];
}

/**
 已保存的账号
 */
- (NSString *)mcsAccountForApp:(NSString *)appkey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:appkey];
}

/**
 已保存的密码
 */
- (NSString *)mcsPasswordForAccount:(NSString *)account {
    NSString *ret = [[NSUserDefaults standardUserDefaults] objectForKey:account];
    if (!ret.length) {
        ret = [self generateMCSPassword];
        [[NSUserDefaults standardUserDefaults] setObject:ret forKey:account];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return ret;
}

/**
 生成随机账号
 */
- (NSString *)generateMCSUsername {
    long currentTimeTamp = [[NSDate date] timeIntervalSince1970];
    NSString *usernameString = [NSString stringWithFormat:@"mcsios%ld", currentTimeTamp];
    NSString *usernameResult = [usernameString
            stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random_uniform(1000)]];
    return usernameResult;
}

/**
 生成随机密码
 */
- (NSString *)generateMCSPassword {
    int number = (arc4random() % 900000) + 100000;
    return [NSString stringWithFormat:@"%d", number];
}

#pragma mark - loginManagerDelegate


/**
 登陆成功回调
 */
- (void)didLoginSuccess {
    //获取评价类型(登录完成请求一次)
    _evaluation = [sClient.mcsManager fetchEvaluationConfigSync];
    _quickQuestions = [sClient.mcsManager fetchQuickQuestionsSync];
    [self unreadMessageCount];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loginResponse && !self.isLogin) {
            self.loginResponse(YES, nil);
            self.loginResponse = nil;
        }
        self.isLogin = YES;
        [self saveAccount:[sClient.loginManager username]];
        [self saveCid:[JXIMClient clientConfig][@"cid"]];
        [kDefaultNotificationCenter postNotificationName:kNotification_loginSucess object:nil];
    });
}

// 登陆失败，若出现账号冲突则重新生成登陆账号
- (void)didLoginFailureWithError:(JXError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error.errorCode == JXErrorTypeUserRemoved ||
            error.errorCode == JXErrorTypePasswordModified ||
            error.errorCode == JXErrorTypeLoginInvalidUsernameOrPassword ||
            error.errorCode == JXErrorTypeLoginUserNameNotExist) {
            [self clearAccount];
            [self loginWithAppKey:[sClient appKey] responseObject:self.loginResponse];
            return;
        }
        self.loginResponse(NO, error);
    });
}

/**
 登出成功回调
 */
- (void)didLogoutSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isLogin = NO;

        _unreadMessageCount = -1;

        if (self.logoutResponseBlock) {
            self.logoutResponseBlock(YES, nil);
        }
    });
}

- (void)didConnectionChanged:(BOOL)isConnected withError:(JXError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isLogin = isConnected;
        if (!isConnected) {
            [kDefaultNotificationCenter postNotificationName:kNotification_disConnected object:nil];
        }
    });
}

// 被强制下线
- (void)didForceLogoutWithError:(JXError *)error {
    if (self.logoutResponseBlock) {
        self.logoutResponseBlock(NO, error);
    }
}

#pragma mark - JXMCSManagerDelegate

// 接受到坐席离线消息
- (void)didReceiveAgentLeaveMessage:(NSDictionary *)info {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.unreadMessageCount++;
}

@end
