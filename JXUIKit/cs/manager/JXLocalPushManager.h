//
//  JXLocalPushManager.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "JXChatViewController.h"

@class JXMessage;

typedef NS_ENUM(NSInteger, JXLocalPushType) {
    kLocalPushTypeMessage = 1001,
    kLocalPushTypeOther
};

@interface JXLocalPushManager : NSObject <UNUserNotificationCenterDelegate, JXClientDelegate>

@property(nonatomic, assign) NSInteger indexPath;

+ (JXLocalPushManager *)sharedInstance;

- (void)registerLocalNotification;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)resetApplicationIconBadgeNumber;

- (void)scheduleLocalNotificationWithMessage:(JXMessage *)message;

- (void)scheduleLocalNotificationWithSession:(id)session;

@end
