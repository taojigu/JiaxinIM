//
//  UIViewController+HUD.h
//

#import <UIKit/UIKit.h>

@interface UIViewController (HUD)

- (void)showHUDMessage:(NSString *)message;

- (void)showMessageWithActivityIndicator:(NSString *)message;

- (void)hideHUD;

@end
