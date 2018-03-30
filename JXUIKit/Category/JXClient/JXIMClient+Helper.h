//
//  JXIMClient+Helper.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "JXClientDelegate.h"
#import "JXIMClient.h"
#import "JXMacros.h"

@interface JXIMClient (Helper)

@property (nonatomic) NSString *appKey;
@property (nonatomic) NSDictionary *clientConfigure;
@property (nonatomic) NSDictionary *launchOptions;

+ (NSString *)appkey;

+ (NSDictionary *)clientConfig;

+ (void)clearClientConfig;

- (void)initializeSDKWithAppKey:(NSString *)key
               andLaunchOptions:(NSDictionary *)launchOptions
                      andConfig:(NSDictionary *)config;

@end
