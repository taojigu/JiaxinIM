//
//  JXHUD.m
//

#import "JXHUD.h"
#import "JXMBProgressHUD.h"

@interface JXHUD() <JXMBProgressHUDDelegate_>
@end

static JXMBProgressHUD *_hud = nil;
@implementation JXHUD

+ (instancetype)sharedHUD {
    static JXHUD *HUD = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HUD = [[JXHUD alloc] init];
    });
    return HUD;
}

- (void)showLongTextMesasge:(NSString *)textMessage {
    [self hideHUD];
    if (_hud == nil) {
        _hud = [[JXMBProgressHUD alloc] initWithView:[self topUIWindow]];
        [[self topUIWindow] addSubview:_hud];

        _hud.mode = JXMBProgressHUDModeText;
        _hud.detailsLabelText = textMessage;
        [_hud show:YES];
    } else {
        _hud.detailsLabelText = textMessage;
        [_hud show:YES];
    }
}

- (void)showLongTextMesasge:(NSString *)textMessage inView:(UIView *)view {
    [self hideHUD];
    if (_hud == nil) {
        _hud = [[JXMBProgressHUD alloc] initWithView:view];
        [view addSubview:_hud];

        _hud.mode = JXMBProgressHUDModeText;
        _hud.detailsLabelText = textMessage;
        [_hud show:YES];
    } else {
        _hud.detailsLabelText = textMessage;
        [_hud show:YES];
    }
}

- (void)showMessage:(NSString *)_message {
    [self hideHUD];
    if (_hud == nil) {
        _hud = [[JXMBProgressHUD alloc] initWithView:[self topUIWindow]];
        [[self topUIWindow] addSubview:_hud];

        _hud.mode = JXMBProgressHUDModeText;
        _hud.labelText = _message;
        [_hud show:YES];
    } else {
        _hud.labelText = _message;
        [_hud show:YES];
    }
}

- (void)showMessage:(NSString *)_message inView:(UIView *)view {
    if (!view) {
        return;
    }
    [self hideHUD];
    if (_hud == nil) {
        _hud = [[JXMBProgressHUD alloc] initWithView:view];
        [view addSubview:_hud];

        _hud.mode = JXMBProgressHUDModeText;
        _hud.labelText = _message;
        [_hud show:YES];
    } else {
        _hud.labelText = _message;
        [_hud show:YES];
    }
}

- (void)showMessage:(NSString *)_message duration:(CGFloat)_duration {
    [self hideHUD];
    [self showMessage:_message];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [_hud hide:NO];
                       [_hud removeFromSuperview];
                       _hud = nil;
                   });
}

- (void)showMessage:(NSString *)_message duration:(CGFloat)_duration inView:(UIView *)view {
    [self hideHUD];
    [self showMessage:_message inView:view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [_hud hide:NO];
                       [_hud removeFromSuperview];
                       _hud = nil;
                   });
}

- (void)showLongTextMessage:(NSString *)_longMessage duration:(CGFloat)_duration {
    [self hideHUD];
    [self showLongTextMesasge:_longMessage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [_hud hide:NO];
                       [_hud removeFromSuperview];
                       _hud = nil;
                   });
}

- (void)showLongTextMessage:(NSString *)_longMessage
                   duration:(CGFloat)_duration
                     inView:(UIView *)view;
{
    [self hideHUD];
    [self showLongTextMesasge:_longMessage inView:view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [_hud hide:NO];
                       [_hud removeFromSuperview];
                       _hud = nil;
                   });
}

- (void)showMessageWithActivityIndicatorView:(NSString *)_message {
    [self hideHUD];
    if (_hud == nil) {
        _hud = [[JXMBProgressHUD alloc] initWithView:[self topUIWindow]];
        [[self topUIWindow] addSubview:_hud];
    }
    _hud.labelText = _message;
    _hud.mode = JXMBProgressHUDModeIndeterminate;
    [_hud show:YES];
}

- (void)showMessageWithActivityIndicatorView:(NSString *)_message inView:(UIView *)view {
    [self hideHUD];
    if (_hud == nil) {
        _hud = [[JXMBProgressHUD alloc] initWithView:view];
        [view addSubview:_hud];
    }
    _hud.labelText = _message;
    _hud.mode = JXMBProgressHUDModeIndeterminate;
    [_hud show:YES];
}

- (void)hideHUD {
    if (_hud) {
        [_hud hide:NO];
        if (_hud.superview) {
            [_hud removeFromSuperview];
        }
        _hud = nil;
    }
}

- (UIWindow *)topUIWindow {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    return [windows lastObject];
}

@end
