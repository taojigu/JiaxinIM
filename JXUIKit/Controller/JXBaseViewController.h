//
//  JXBaseViewController.h
//

#import <UIKit/UIKit.h>

#import "JXMacros.h"
#import "JXLocalizeHelper.h"
#import "UIView+Extends.h"
#import "UIViewController+HUD.h"

@interface JXBaseViewController : UIViewController

@property(nonatomic, assign, getter=isModal, readonly) BOOL modal;

@property(nonatomic, assign) BOOL hideNavBar;

- (void)popSelf;

- (void)popSelfWithoutAnimation;

- (void)popToRoot;

- (void)viewDidPop;


/**
 设置控制器导航栏返回item为默认
 */
- (void)setupDefaultLeftButtonItem;


/**
 设置控制器导航栏返回item为文本

 @param title 返回item文本
 */
- (void)setupDefaultLeftButtonItemWithTitle:(NSString *)title;


/**
 设置导航栏右边为自定义文本

 @param title 自定义文本
 @param action 点击后的回调
 */
- (void)setupRightBarButtonItemWithTitle:(NSString *)title andAction:(void (^)(id sender))action;


/**
 设置导航栏右边为自定义图片

 @param image 自定义图片
 @param action 点击后的回调
 */
- (void)setupRightBarButtonItemWithImage:(UIImage *)image andAction:(void (^)(id sender))action;

@end
