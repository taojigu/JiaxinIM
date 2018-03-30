//
//  AppDelegate.m
//  JiaXinDemo
//
//  Created by 顾吉涛 on 2018/3/29.
//  Copyright © 2018年 顾吉涛. All rights reserved.
//

#import "AppDelegate.h"
#import "JXLocalPushManager.h"
#import <JXIMClient.h>
#import <JXIMClient+Helper.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *jxAppKey = @"1234567890";
    // set your own app key here, 'nil' only use for demo
    // register SDK
    NSDictionary *clientConfig = @{@"cid" : @"45",
                                   @"crm" : @{@"name" : @"holl", @"phone" : @"10010"}};
    [sClient initializeSDKWithAppKey:jxAppKey andLaunchOptions:nil andConfig:clientConfig];
    
    // handle app badge count on demand
    // application.applicationIconBadgeNumber = 0;
 
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [sClient bindDeviceToken:deviceToken];;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
