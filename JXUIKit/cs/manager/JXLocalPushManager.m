//
//  JXLocalPushManager.m
//

#import "JXLocalPushManager.h"
#import "JXChatViewController.h"

#define JXMCSPush @"JXMCS"

@interface JXLocalPushManager () {
    NSInteger unreadNum;
}

@property(nonatomic, strong) UIView *localPushView;

@end

@implementation JXLocalPushManager

+ (JXLocalPushManager *)sharedInstance {
    static JXLocalPushManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JXLocalPushManager alloc] init];
    });
    return sharedInstance;
}

//注册本地推送
- (void)registerLocalNotification {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application
                registerUserNotificationSettings:
                        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
                                                                     UIUserNotificationTypeBadge |
                                                                     UIUserNotificationTypeSound
                                                          categories:nil]];
    }
}

//接收到本地通知的回调
- (void)didReceiveLocalNotification:(UILocalNotification *)notification {
    if (notification.alertBody == nil) {
        return;
    }
    if (![[self topViewController] isKindOfClass:[JXChatViewController class]] &&
        [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        UILabel *label = [self.localPushView viewWithTag:3];
        label.text = notification.alertBody;
        AudioServicesPlayAlertSound(kSystemRemindVoiceTypeMessage);
        [UIView animateWithDuration:0.5
                delay:0.5
                options:UIViewAnimationOptionTransitionFlipFromTop
                animations:^{
                    self.localPushView.transform = CGAffineTransformMakeTranslation(0, 65);
                }
                completion:^(BOOL finished) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                                       [UIView animateWithDuration:0.5
                                                        animations:^{
                                                            self.localPushView.transform =
                                                                    CGAffineTransformIdentity;
                                                        }];
                                   });
                }];
    }
}

- (void)resetApplicationIconBadgeNumber {
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 0;
    // 获得 UIApplication
    unreadNum = 0;
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    if (localArray) {
        for (UILocalNotification *noti in localArray) {
            [app cancelLocalNotification:noti];
        }
    }
}

- (void)scheduleLocalNotificationWithSession:(id)session {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [self sendLocalNotification:notification userInfo:@{JXMCSPush : session} alertBody:JXUIString(@"agent message")];
}

- (void)scheduleLocalNotificationWithMessage:(JXMessage *)message {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ||
        ![[self topViewController] isKindOfClass:[JXChatViewController class]]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        switch (message.type) {
            case JXMessageTypeText:
                notification.alertBody = [NSString
                        stringWithFormat:@"%@ : %@", message.sender,
                                         [NSString convertToSystemEmoji:message.textToDisplay]];
                break;
            case JXMessageTypeImage:
                notification.alertBody =
                        [NSString stringWithFormat:@"%@", JXUIString(@"image message")];
                break;
            case JXMessageTypeAudio:
                notification.alertBody =
                        [NSString stringWithFormat:@"%@", JXUIString(@"voice message")];
                break;
            case JXMessageTypeVideo:
                notification.alertBody =
                        [NSString stringWithFormat:@"%@", JXUIString(@"video message")];
                ;
                break;
            default:
                break;
        }
        [self sendLocalNotification:notification userInfo:nil alertBody:nil];
    }
}

- (void)sendLocalNotification:(UILocalNotification *)notification
                     userInfo:(NSDictionary *)userInfo
                    alertBody:(NSString *)alertBody {
    if (!notification) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unreadNum++;
        if (IOSVersion < 10.0) {
            NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:0];
            notification.fireDate = pushDate;
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.repeatInterval = kCFCalendarUnitDay;
            notification.soundName = UILocalNotificationDefaultSoundName;
            if (alertBody) {
                notification.alertBody = alertBody;
            }
            if (userInfo) {
                notification.userInfo = userInfo;
            }
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        } else {
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.body = notification.alertBody;
            content.userInfo = notification.userInfo;
            content.sound = [UNNotificationSound defaultSound];
            UNTimeIntervalNotificationTrigger *trigger =
                    [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:JXMCSPush
                                                                                  content:content
                                                                                  trigger:trigger];
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                                   withCompletionHandler:nil];
        }
    });
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionBadge
                      | UNNotificationPresentationOptionSound
                      | UNNotificationPresentationOptionAlert);
}

#pragma mark - JXChatManagerDelegate

- (void)didReceiveMessage:(JXMessage *)message {
    if ([[self topViewController] isKindOfClass:[UIAlertController class]]) {
        return;
    }
    if (![[self topViewController] isKindOfClass:[JXChatViewController class]]) {
        [[JXLocalPushManager sharedInstance] scheduleLocalNotificationWithMessage:message];
    }
}

#pragma mark - private

- (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication]
                                                                 .keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:
        (UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self
                topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self
                topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
