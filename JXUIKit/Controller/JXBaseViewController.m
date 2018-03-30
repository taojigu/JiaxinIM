//
//  JXBaseViewController.m
//

#import "JXBaseViewController.h"

@interface JXBaseViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic, assign) BOOL isRootNav;
@property(nonatomic, copy) void (^actionBlock)(id sender);

@end

@implementation JXBaseViewController

+ (void)initialize {
//    UINavigationBar *nav = [UINavigationBar appearance];
//    nav.tintColor = [UIColor whiteColor];
}

- (void)dealloc {
    NSLog(@"******dealloc controller class:%@************", [self class]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    if (self.navigationController.viewControllers.count <= 1) {
        _isRootNav = YES;
    }
    _hideNavBar = NO;
}

- (UINavigationBar *)navigationBar {
    return self.navigationController.navigationBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:_hideNavBar animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:_hideNavBar animated:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (_hideNavBar) {
        [self.navigationBar setAlpha:0];
    } else {
        [self.navigationBar setAlpha:1.0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isRootNav) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_isRootNav) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [self viewDidPop];
    }
}

#pragma mark - 私有方法

- (void)viewDidPop {
}

- (void)popSelfWithoutAnimation {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)popSelf {
    if (self.navigationController) {
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)popToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)navigationRightBarItemDidClick:(id)sender {
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}

- (void)configureLeftBarButtonItemWithButton:(UIButton *)sender {
    [sender addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [sender setShowsTouchWhenHighlighted:YES];
    [sender setFrame:CGRectMake(0, 0, 44, 44)];
    if (IOSVersion >= 11.f) {
        sender.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:sender];

    self.navigationItem.leftBarButtonItems = nil;
    if (IOSVersion >= 7.0) {
        UIBarButtonItem *fixitem =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                              target:nil
                                                              action:nil];
        fixitem.width = -18;
        [self.navigationItem setLeftBarButtonItems:@[ fixitem, backItem ]];
    } else {
        [self.navigationItem setLeftBarButtonItem:backItem];
    }
}

#pragma mark - 外部方法

- (void)setupDefaultLeftButtonItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:JXChatImage(@"back_unclick") forState:UIControlStateNormal];
    [self configureLeftBarButtonItemWithButton:btn];
}

- (void)setupDefaultLeftButtonItemWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = JXSystemFont(17.0);
    [self configureLeftBarButtonItemWithButton:btn];
}

- (void)setupRightBarButtonItemWithTitle:(NSString *)title andAction:(void (^)(id))action {
    self.actionBlock = action;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = JXSystemFont(17.0);
    [btn setFrame:CGRectMake(0, 0, 36, 36)];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -8)];
    [btn addTarget:self
                      action:@selector(navigationRightBarItemDidClick:)
            forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *itemFinish = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (IOSVersion >= 7.0) {
        UIBarButtonItem *itemAdjust =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                              target:nil
                                                              action:nil];
        itemAdjust.width = -18;
        [self.navigationItem setRightBarButtonItems:@[ itemFinish, itemAdjust ]];
    } else {
        [self.navigationItem setRightBarButtonItem:itemFinish];
    }
}

- (void)setupRightBarButtonItemWithImage:(UIImage *)image andAction:(void (^)(id))action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionBlock = action;
    [btn setImage:image forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 36, 36)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -8)];
    [btn addTarget:self
                      action:@selector(navigationRightBarItemDidClick:)
            forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *itemFinish = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (IOSVersion >= 7.0) {
        UIBarButtonItem *itemAdjust =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                              target:nil
                                                              action:nil];
        itemAdjust.width = -18;
        [self.navigationItem setRightBarButtonItems:@[ itemFinish, itemAdjust ]];
    } else {
        [self.navigationItem setRightBarButtonItem:itemFinish];
    }
}

@end
