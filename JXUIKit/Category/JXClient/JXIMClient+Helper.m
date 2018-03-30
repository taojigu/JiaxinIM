//
//  JXIMClient+Helper.m
//

#import "JXIMClient+Helper.h"

#import "JXError+LocalDescription.h"
#import "JXHUD.h"
#import <objc/runtime.h>

#import "JXMCSUserManager.h"
#import "JXLocalPushManager.h"


@implementation JXIMClient (Helper)

- (NSString *)appKey {
    return objc_getAssociatedObject(self, @selector(appKey));
}

- (void)setAppKey:(NSString *)appKey {
    objc_setAssociatedObject(self, @selector(appKey), appKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)clientConfigure {
    return objc_getAssociatedObject(self, @selector(clientConfigure));
}

- (void)setClientConfigure:(NSDictionary *)clientConfigure {
    objc_setAssociatedObject(self, @selector(clientConfigure), clientConfigure, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)launchOptions {
    return objc_getAssociatedObject(self, @selector(launchOptions));
}

- (void)setLaunchOptions:(NSDictionary *)launchOptions {
    objc_setAssociatedObject(self, @selector(launchOptions), launchOptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - loadConfig

+ (NSString *)appkey {
    return [self sharedInstance].appKey;
}

+ (NSDictionary *)clientConfig {
    return [self sharedInstance].clientConfigure;
}

+ (void)clearClientConfig {
    [self sharedInstance].clientConfigure = nil;
}

- (void)initializeSDKWithAppKey:(NSString *)key
               andLaunchOptions:(NSDictionary *)launchOptions
                      andConfig:(NSDictionary *)config {
    
    NSParameterAssert(key);
    self.appKey = key;
    if (launchOptions) {
        self.launchOptions = launchOptions;
    }
    if (config) {
        self.clientConfigure = config;
    }
    UIApplication *app = [UIApplication sharedApplication];
    [self setupAppDelegateToClient];
    [self registerAPNS:app];

    [[JXLocalPushManager sharedInstance] registerLocalNotification];
    if (key.length) {
        JXError *error = [self registerSDKWithAppKey:key];
        if (error) {
            [sJXHUD showMessage:[error getLocalDescription] duration:1.4];
        }
    }
}

#pragma mark - register apns

- (void)registerAPNS:(UIApplication *)application {
#if !TARGET_IPHONE_SIMULATOR
    if (IOSVersion >= 10.0) {    // iOS10
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = (id<UNUserNotificationCenterDelegate>)[JXLocalPushManager sharedInstance];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
                                                 UNAuthorizationOptionSound |
                                                 UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                  if (!error) {
                                  }
                              }];
        [application registerForRemoteNotifications];
    } else if (IOSVersion >= 8.0) {    // iOS8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                                 UIUserNotificationTypeSound
                      categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {    // iOS7
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                        UIRemoteNotificationTypeSound |
                                                        UIRemoteNotificationTypeAlert];
    }
#endif
}

#pragma mark - app delegate notifications

- (void)setupAppDelegateToClient {
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidEnterBackground:)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appWillEnterForeground:)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidFinishLaunching:)
                                       name:UIApplicationDidFinishLaunchingNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidBecomeActive:)
                                       name:UIApplicationDidBecomeActiveNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appWillResignActive:)
                                       name:UIApplicationWillResignActiveNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidReceiveMemoryWarning:)
                                       name:UIApplicationDidReceiveMemoryWarningNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appWillTerminate:)
                                       name:UIApplicationWillTerminateNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appProtectedDataWillBecomeUnavailable:)
                                       name:UIApplicationProtectedDataWillBecomeUnavailable
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appProtectedDataDidBecomeAvailable:)
                                       name:UIApplicationProtectedDataDidBecomeAvailable
                                     object:nil];
}

@end
