//
//  UIViewController+HUD.m
//

#import "UIViewController+HUD.h"
#import "JXMBProgressHUD.h"
#import <objc/runtime.h>

static const void *kHUDKey = &kHUDKey;

@implementation UIViewController (HUD)

- (JXMBProgressHUD *)HUD {
    return objc_getAssociatedObject(self, kHUDKey);
}

- (JXMBProgressHUD *)createHUDWithMode:(JXMBProgressHUDMode)mode {
    JXMBProgressHUD *ret = self.HUD;
    if (ret) {
        [ret hide:YES];
        ret.mode = mode;
        return ret;
    }
    ret = [[JXMBProgressHUD alloc] initWithView:self.view];
    objc_setAssociatedObject(self, kHUDKey, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.view addSubview:ret];
    ret.mode = mode;
    return ret;
}

- (void)showHUDMessage:(NSString *)message {
    JXMBProgressHUD *hud = [self createHUDWithMode:JXMBProgressHUDModeText];
    hud.labelText = message;
    [hud show:YES];
}

- (void)showMessageWithActivityIndicator:(NSString *)message {
    JXMBProgressHUD *hud = [self createHUDWithMode:JXMBProgressHUDModeIndeterminate];
    hud.labelText = message;
    [hud show:YES];
}

- (void)hideHUD {
    [[self HUD] hide:YES];
}

@end
