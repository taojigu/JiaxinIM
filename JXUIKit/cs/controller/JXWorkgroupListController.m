//
//  JXCSViewController.m
//

#import "JXWorkgroupListController.h"
#import "JXBadgeButton.h"
#import "JXMCSUserManager.h"
#import "JXMcsChatViewController.h"
#import "JXMsgBoxViewController.h"
#import "JXWebViewController.h"
#import "UINavigationController+JXCategory.h"

@interface JXWorkgroupListController ()

@property(nonatomic, strong) NSMutableArray *csDataSource;
@property(nonatomic, weak) JXBadgeButton *msgBoxBtn;

@end

@implementation JXWorkgroupListController

- (void)viewDidLoad {
    self.style = UITableViewStyleGrouped;
    [super viewDidLoad];

    [self setTitle:JXUIString(@"workgroup title")];
    [self setupDefaultLeftButtonItem];
    WEAKSELF;
    [self.navigationController setPopItemAction:^(UINavigationController *navC) {
        if (navC.topViewController == weakSelf) {
            return ;
        }
        if ([JXMCSUserManager sharedInstance].originNavImage) {
            [navC.navigationBar setBackgroundImage:[JXMCSUserManager sharedInstance].originNavImage
                                     forBarMetrics:UIBarMetricsDefault];
        }
        [navC.navigationBar setTitleTextAttributes:[JXMCSUserManager sharedInstance].originNavAttributes];
    }];
    
    if ([JXMCSUserManager sharedInstance].config.showMsgBoxItem) {
         [self setupRightButtonItem];
    }
    [[JXMCSUserManager sharedInstance] addObserver:self
                                        forKeyPath:@"unreadMessageCount"
                                           options:NSKeyValueObservingOptionNew
                                           context:nil];
    if (self.workgroupList.count) {
        _csDataSource = [NSMutableArray arrayWithArray:self.workgroupList];
        [self.tableView reloadData];
    } else {
        [self showMessageWithActivityIndicator:nil];
        [sClient.mcsManager fetchCustomServicesWithCallback:^(id responseObject, JXError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHUD];
                if (!error) {
                    _csDataSource = responseObject;
                    if (_csDataSource.count == 1) {
                        [self gotoChatView:_csDataSource.firstObject];
                        return;
                    } else if (_csDataSource.count == 0) {
                        sJXHUDMes(JXUIString(@"no workgroup tips"), 1.f);
                        [self popSelf];
                    }
                    [self.tableView reloadData];
                } else {
                    sJXHUDMes(JXUIString(@"fail to get workgroup tips"), 1.f);
                    [self popSelf];
                }
            });
        }];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([JXMCSUserManager sharedInstance].config.navColor) {
        UIImage *image = [UIImage imageWithColor:[JXMCSUserManager sharedInstance].config.navColor];
        [self.navigationController.navigationBar setBackgroundImage:image
                                                      forBarMetrics:(UIBarMetricsDefault)];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName :[JXMCSUserManager sharedInstance].config.navTitleColor,
                                                                      NSFontAttributeName : [JXMCSUserManager sharedInstance].config.navFont
                                                                      }];
}

- (void)viewDidPop {
    [super viewDidPop];
    @try {
        [[JXMCSUserManager sharedInstance] removeObserver:self forKeyPath:@"unreadMessageCount"];
    } @catch (NSException *exception) {
        JXLog(@"%@", exception.reason);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _csDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cs";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    JXWorkgroup *group = _csDataSource[indexPath.row];
    cell.textLabel.text = group.displayName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.000001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JXWorkgroup *service = [[JXIMClient sharedInstance].mcsManager activeService];
    JXWorkgroup *selected = _csDataSource[indexPath.row];
    
    if (service && service.status != JXMCSUserStatusInRobot && service != selected) {
        NSString *showString = [NSString
                stringWithFormat:JXUIString(@"already in workgroup tips"), service.displayName];
        [sJXHUD showLongTextMessage:showString duration:1.6];
    } else {
        [self gotoChatView:selected];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger count = [change[NSKeyValueChangeNewKey] integerValue];
        self.msgBoxBtn.badgeValue = [NSString stringWithFormat:@"%zd", count];
    });
}

#pragma mark pravite methods

- (void)setupRightButtonItem {
    UIButton *leavMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leavMsgBtn addTarget:self
                      action:@selector(leaveMessageOnline)
            forControlEvents:UIControlEventTouchUpInside];
    [leavMsgBtn setImage:[JXMCSUserManager sharedInstance].config.leaveMsgItemImage
                forState:UIControlStateNormal];
    leavMsgBtn.jx_size = CGSizeMake(28, 28);
    UIBarButtonItem *leavMsgItem = [[UIBarButtonItem alloc] initWithCustomView:leavMsgBtn];

    JXBadgeButton *msgBoxView = [JXBadgeButton buttonWithType:UIButtonTypeCustom];
    NSInteger count = [JXMCSUserManager sharedInstance].unreadMessageCount;
    msgBoxView.badgeValue = [NSString stringWithFormat:@"%zd", count];
    [msgBoxView setImage:[JXMCSUserManager sharedInstance].config.msgBoxItemImage forState:UIControlStateNormal];
    msgBoxView.jx_size = CGSizeMake(28, 28);
    [msgBoxView addTarget:self
                      action:@selector(openMsgBox)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *msgBoxItem = [[UIBarButtonItem alloc] initWithCustomView:msgBoxView];
    self.navigationItem.rightBarButtonItems = @[ msgBoxItem, leavMsgItem ];
    self.msgBoxBtn = msgBoxView;
}

/**
 进入聊天界面
 */
- (void)gotoChatView:(JXWorkgroup *)workgroup {
    if (!workgroup) return;
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:NO];
    JXMcsChatViewController *chatVC = [[JXMcsChatViewController alloc] initWithWorkgroup:workgroup];
    [navController pushViewController:chatVC animated:IOSVersion > 8.0];
}

/**
 打开离线消息界面
 */
- (void)leaveMessageOnline {
    [[JXMCSUserManager sharedInstance] leaveMessageOnlineForUI:self workgroup:nil];
}

// 打开消息盒子
- (void)openMsgBox {
    JXMsgBoxViewController *msgBoxVC = [[JXMsgBoxViewController alloc] init];
    [self.navigationController pushViewController:msgBoxVC animated:YES];
}

@end
