//
//  JXHUD.h
//

#import <UIKit/UIKit.h>

#define sJXHUD [JXHUD sharedHUD]
#define sJXHUDMes(_message_, _duration_) [sJXHUD showMessage:_message_ duration:_duration_]

@interface JXHUD : UIView

+ (instancetype)sharedHUD;

- (void)hideHUD;

- (void)showMessage:(NSString *)_message;
- (void)showMessage:(NSString *)_message duration:(CGFloat)_duration;
- (void)showMessageWithActivityIndicatorView:(NSString *)_message;

- (void)showLongTextMesasge:(NSString *)textMessage;
- (void)showLongTextMessage:(NSString *)_longMessage duration:(CGFloat)_duration;

- (void)showMessage:(NSString *)_message inView:(UIView *)view;
- (void)showMessage:(NSString *)_message duration:(CGFloat)_duration inView:(UIView *)view;
- (void)showMessageWithActivityIndicatorView:(NSString *)_message inView:(UIView *)view;
- (void)showLongTextMesasge:(NSString *)textMessage inView:(UIView *)view;
- (void)showLongTextMessage:(NSString *)_longMessage
                   duration:(CGFloat)_duration
                     inView:(UIView *)view;

@end
