//
//  JXMcsChatViewController.m
//

#import "JXMcsChatViewController.h"
#import "JXMsgBoxViewController.h"

#import "JXAppConfig+Extends.h"
#import "JXChatViewController+MessageSend.h"
#import "JXChatViewController+Toolbar.h"
#import "JXWebViewController.h"
#import "UINavigationController+JXCategory.h"

#import "JXCommandView.h"
#import "JXEvalMessageCell.h"
#import "JXTipView.h"
#import "NSTimer+Category.h"

#import "JXBadgeButton.h"
#import "JXMCSUserManager.h"

#import "MJRefresh.h"

#define transAgentTypeTag 100
#define resendMessageTag 101
#define transRobotTag 102
#define submitReviewTag 103
#define endSessionTag 104

@interface JXMcsChatViewController ()<UIAlertViewDelegate, JXCommandViewDelegate,
                                      JXChatViewControllerDelegate, UINavigationBarDelegate>

@property(nonatomic, strong) UIButton *changeCSBtn;
@property(nonatomic, strong) JXBadgeButton *msgBoxBtn;
@property(nonatomic, strong) JXTipView *tipView;
@property(nonatomic, strong) JXTipView *subTipView;
@property(nonatomic, strong) UIImageView *onlineImage;
@property(nonatomic, strong) JXCommandView *commandView;    /// 用于选择满意度评价及快捷提问

@property(nonatomic, assign) BOOL showTipView;
@property(nonatomic, assign) BOOL showSubTipeView;
@property(nonatomic, assign) BOOL isRobot;         /// 判断当前是否为机器人服务状态
@property(nonatomic, assign) BOOL hasRobot;        /// 判断是否有机器人变量
@property(nonatomic, assign) BOOL hasEvaluated;    /// 是否已经评价过变量
@property(nonatomic, assign) BOOL hasAgentTips;   /// 是否已下发欢迎语

@property(nonatomic, strong) JXWorkgroup *workgroup;
@property(nonatomic, strong) JXMessage *evaluationRequest;
@property(nonatomic, strong) JXMessage *resendMessage;
@property(nonatomic, strong) NSTimer *timer;    /// 用于定时发送预知消息
@property(nonatomic, copy) NSString *lastForeseeText;
@property(nonatomic, copy) NSString *serviceNickname;
@property(nonatomic, copy) dispatch_block_t submitReviewBlock;

@end

@implementation JXMcsChatViewController

- (instancetype)initWithWorkgroup:(JXWorkgroup *)workgroup {
    JXConversation *conversation =
            [sClient.chatManager conversationForChatter:workgroup.serviceID andType:JXChatTypeCS];
    if (self = [super initWithConversation:conversation]) {
        self.hidesBottomBarWhenPushed = YES;
        _workgroup = workgroup;
        // 根据开发者者配置决定是否显示语音按钮和表情按钮
        self.allowVoiceChat = [JXAppConfig sharedInstance].userSendAudioFlag;
        self.allowEmojiChat = [JXAppConfig sharedInstance].userEmoticonFlag;
        _isRobot = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRightItem];
    self.title = self.workgroup.displayName;
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
    self.changeCSBtn.userInteractionEnabled = NO;
    self.delegate = self;
    self.tableView.backgroundColor = JXColorWithRGB(240, 240, 240);

    // 设置tableview下拉刷新
    [self setupTableViewRefreshHeader];
    
    [[JXMCSUserManager sharedInstance] addObserver:self
                                        forKeyPath:@"unreadMessageCount"
                                           options:NSKeyValueObservingOptionNew
                                           context:nil];

    // 加载数据并请求客服
    [self loadAndRequire];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (void)dealloc {
    @try {
        [[JXMCSUserManager sharedInstance] removeObserver:self forKeyPath:@"unreadMessageCount"];
    } @catch (NSException *exception) {
        JXLog(@"%@", exception.reason);
    }
}

- (void)viewDidPop {
    [super viewDidPop];
    [sJXHUD hideHUD];
    if (_timer) {
        // 发送消息编辑结束消息
        [self sendForeseeMessage:nil];
        // 销毁定时器
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - UI 定义区

#pragma mark 设置navigationBar相关方法

// 返回标题栏title
- (NSAttributedString *)titleStringWith:(NSString *)title andImage:(UIImage *)image {
    if (!image) {
        return [[NSMutableAttributedString alloc] initWithString:title];
    }
    NSString *text = [NSString stringWithFormat:@"  %@", title];
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:text];

    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    textAttachment.image = image;

    NSAttributedString *imageStr =
            [NSAttributedString attributedStringWithAttachment:textAttachment];
    [ret replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:imageStr];
    return ret;
}

/**
 *  设置标题栏
 *
 *  @param isInService 客服是否在线
 *  @param title  标题文本
 */
- (void)setupTitleViewWithOnlineStatus:(BOOL)isInService andTitle:(NSString *)title {
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    if (!label) {
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [JXMCSUserManager sharedInstance].config.navFont;
        label.textColor = [JXMCSUserManager sharedInstance].config.navTitleColor;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
    }
    if (!title) return;
    if (isInService) {
        label.attributedText = [self titleStringWith:title andImage:JXChatImage(@"online")];
    } else {
        label.attributedText = [self titleStringWith:title andImage:nil];
    }
    [label sizeToFit];
}

// 请求人工按钮
- (void)setupRightItem {
    // 转人工按钮
    _changeCSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_changeCSBtn addTarget:self
                      action:@selector(transferCustomerService)
            forControlEvents:UIControlEventTouchUpInside];
    [_changeCSBtn setImage:[JXMCSUserManager sharedInstance].config.requestCSItemImage
                  forState:UIControlStateNormal];
    // 消息箱按钮
    _msgBoxBtn = [JXBadgeButton buttonWithType:UIButtonTypeCustom];
    [_msgBoxBtn addTarget:self
                      action:@selector(openMsgBox)
            forControlEvents:UIControlEventTouchUpInside];
    [_msgBoxBtn setImage:[JXMCSUserManager sharedInstance].config.msgBoxItemImage
                forState:UIControlStateNormal];
    _msgBoxBtn.badgeValue = [NSString
            stringWithFormat:@"%zd", [JXMCSUserManager sharedInstance].unreadMessageCount];
    
    _msgBoxBtn.jx_size = CGSizeMake(28, 28);
    _changeCSBtn.jx_size = _msgBoxBtn.jx_size;

    UIBarButtonItem *msgBoxItem = [[UIBarButtonItem alloc] initWithCustomView:_msgBoxBtn];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_changeCSBtn];
    if ([JXMCSUserManager sharedInstance].config.showMsgBoxItem) {
       [self.navigationItem setRightBarButtonItems:@[ msgBoxItem, rightItem ]];
    } else {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

/**
 设置右上角按钮样式
 */
- (void)setupChangeCSBtnWithInService:(BOOL)isInService andIsHidden:(BOOL)hidden {
    if (!_changeCSBtn) return;
    _changeCSBtn.hidden = hidden;

    if (isInService) {
        // 人工客服服务状态设置为退出聊天按钮
        [_changeCSBtn setImage:[JXMCSUserManager sharedInstance].config.terminalCSItemImage forState:UIControlStateNormal];
        [_changeCSBtn addTarget:self
                          action:@selector(terminateSession)
                forControlEvents:UIControlEventTouchUpInside];
    } else {
        // 非人工客服状态设置请求人工客服服务按钮
        [_changeCSBtn addTarget:self
                          action:@selector(transferCustomerService)
                forControlEvents:UIControlEventTouchUpInside];
        [_changeCSBtn setImage:[JXMCSUserManager sharedInstance].config.requestCSItemImage forState:UIControlStateNormal];
    }
}

#pragma mark toolBar相关方法

//设置ChatToolbar中moreView的类型
- (void)setupToolbarItemsWithStatus:(JXMCSUserStatus)status {
    self.messageToolbar.moreView = nil;
    [self.messageToolbar endEditing:YES];

    // 隐藏messageToolbar语音按钮和表情按钮
    self.messageToolbar.isHiddenRecordBtn = YES;
    self.messageToolbar.isHiddenEmojiBtn = YES;

    WEAKSELF;
    // 添加快捷提问item，如果快捷提问数为空，则不显示改item
    if ([[JXMCSUserManager sharedInstance] quickQuestions].count) {
        [self toolbarAddCustomItemWithTitle:JXUIString(@"quick questions")
                                     andImage:JXChatImage(@"more_question")
                                    andAction:^(NSInteger index) {
                                        [weakSelf showCommandView:NO];
                                    }];
    }

    switch (status) {
        case JXMCSUserStatusInService: {
            // 判断是否开启访客主动满意度
            if ([JXAppConfig sharedInstance].visitorSatisfyFlag) {
                [self toolbarAddCustomItemWithTitle:JXUIString(@"evaluation")
                                             andImage:JXChatImage(@"more_comment")
                                            andAction:^(NSInteger index) {
                                                [weakSelf showCommandView:YES];
                                            }];
            }
        }
        case JXMCSUserStatusAgentOffline:
        case JXMCSUserStatusWaiting: {
            self.messageToolbar.isHiddenRecordBtn = !self.allowVoiceChat;
            self.messageToolbar.isHiddenEmojiBtn = NO;

            // 添加拍照item
            [self toolbarAddCameraItemWithTitle:JXUIString(@"photo")
                                         andImage:JXChatImage(@"more_photo")];

            // 添加相册item
            [self toolBarAddPhotoItemWithTitle:JXUIString(@"album")
                                        andImage:JXChatImage(@"more_image")];

            // 添加小视频item
            if ([JXAppConfig sharedInstance].userSendVideoFlag) {
                [self toolbarAddVideoItemWithTitle:JXUIString(@"video")
                andImage:JXChatImage(@"eye")];
            }
        } break;
        default:
            break;
    }
}

#pragma mark tipView相关方法

/**
 *  显示tipView
 */
- (void)setShowTipView:(BOOL)showTipView {
    if (_showTipView == showTipView) {
        return;
    }
    _showTipView = showTipView;
    if (showTipView) {
        [self.view addSubview:self.tipView];
        [self.view bringSubviewToFront:self.tipView];
    } else {
        [self.tipView removeFromSuperview];
        self.tipView = nil;
        self.showSubTipeView = NO;
    }
    self.messageToolbar.hidden = NO;
}

- (void)setShowSubTipeView:(BOOL)showSubTipeView {
    if (_showSubTipeView == showSubTipeView) {
        return;
    }
    _showSubTipeView = showSubTipeView;
    if (showSubTipeView) {
        [self.view addSubview:self.subTipView];
        [self.view bringSubviewToFront:self.subTipView];
    } else {
        [self.subTipView removeFromSuperview];
        self.subTipView = nil;
    }
    self.messageToolbar.hidden = NO;
}

- (void)setIsRobot:(BOOL)isRobot {
    _isRobot = isRobot;
    [_changeCSBtn setHidden:!self.isRobot];
}

/**
 *  展示快捷提问或满意度评价view
 *
 *  @param isEval 是否为满意度评价
 */
- (void)showCommandView:(BOOL)isEval {
    [self.messageToolbar endEditing:YES];
    if (_commandView) [_commandView hideView];

    NSString *title;
    id model;
    if (isEval) {
        title = JXUIString(@"evaluation");
        model = [[JXMCSUserManager sharedInstance] evaluation];
    } else {
        title = JXUIString(@"quick questions");
        model = [[JXMCSUserManager sharedInstance] quickQuestions];
    }
    _commandView = [[JXCommandView alloc] initWithTtile:title delegate:self model:model frame:self.view.bounds];
    [self.messageToolbar resignFirstResponder];
    [_commandView showInView:self.view];
}

#pragma mark - UI内容控制

// 设置下拉刷新
- (void)setupTableViewRefreshHeader {
    // 从服务端加载更多消息
    WEAKSELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        JXMessage *firstMsg = weakSelf.dataSource.count ? weakSelf.dataSource[1] : nil;
        [weakSelf loadMessagesBefore:firstMsg];
        [weakSelf.tableView.mj_header endRefreshing];
//        [sClient.mcsManager
//                fetchChatLogForConversation:weakSelf.conversation
//                                  withLimit:20
//                                fromMessage:firstMsg
//                               withCallBack:^(NSArray *historyMessages, JXError *error) {
//                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                       [weakSelf.tableView.mj_header endRefreshing];
//                                       if (error) {
//                                           JXLog(@"%@", [error description]);
//                                       } else {
//                                           BOOL refresh = firstMsg ? NO : YES;
//                                           [weakSelf insertHistoryMessages:historyMessages
//                                                                   refresh:refresh];
//                                       }
//                                   });
//                               }];
    }];
}

// 加载消息并请求服务
- (void)loadAndRequire {
    WEAKSELF;
    [self loadMessagesBefore:nil];
    [weakSelf showMessageWithActivityIndicator:JXUIString(@"loading")];
    [sClient.mcsManager requestCustomerService:weakSelf.workgroup];
//    if (!self.dataSource.count && !self.conversation.messageIds.count) {
//        [sClient.mcsManager
//                fetchChatLogForConversation:self.conversation
//                                  withLimit:20
//                                fromMessage:nil
//                               withCallBack:^(NSArray *historyMessages, JXError *error) {
//                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                       [weakSelf hideHUD];
//                                       if (error) {
//                                           JXLog(@"%@", [error description]);
//                                       } else {
//                                           [weakSelf insertHistoryMessages:historyMessages
//                                                                   refresh:YES];
//                                       }
//                                       [sClient.mcsManager requestCustomerService:weakSelf.workgroup];
//                                   });
//                               }];
//    } else {
//        [sClient.mcsManager requestCustomerService:_workgroup];
//    }
}

// 插入本地提示消息
- (void)addTipsMessage:(NSString *)content {
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    [message setTipsContent:content];
    [self addMessage:message];
}

// 插入本地系统消息
- (void)addTempMessage:(NSString *)content {
    JXMessage *message =
            [[JXMessage alloc] initWithSender:JXUIString(@"system name") andType:JXChatTypeCS];
    [message setTextContent:content];
    message.extData[@"isSystem"] = @(1);
    [self addMessage:message];
}

// 请求人工客服
- (void)transferCustomerService {
    if (self.isRobot) {
        UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:JXUIString(@"switch agent title")
                                           message:JXUIString(@"switch agent question")
                                          delegate:self
                                 cancelButtonTitle:JXUIString(@"cancel")
                                 otherButtonTitles:JXUIString(@"ok"), nil];
        alertView.tag = transAgentTypeTag;
        [alertView show];
    }
}

// 关闭会话
- (void)terminateSession {
    if ([JXAppConfig sharedInstance].satisfyNotifyFlag) {
        UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:JXUIString(@"end session title")
                                           message:JXUIString(@"end session question")
                                          delegate:self
                                 cancelButtonTitle:JXUIString(@"cancel")
                                 otherButtonTitles:JXUIString(@"ok"), nil];
        alertView.tag = endSessionTag;
        [alertView show];
    }
}

// 在线留言
- (void)leaveMessageOnline {
    [[JXMCSUserManager sharedInstance] leaveMessageOnlineForUI:self workgroup:self.workgroup];
    [sClient.mcsManager cancelWait];
}

// 显示未读消息通知
- (void)showMsgBoxUnreadTip {
    if (![JXMCSUserManager sharedInstance].unreadMessageCount) {    // 未读消息为空不显示提示
        self.showTipView = NO;
        return;
    } else if (self.showTipView) {    // 如果当前为显示请求客服排队状态不显示通知
        return;
    }

    JXTipView *tipView = self.tipView;
    tipView.contentString = JXUIString(@"unread message tips");

    NSDictionary *attDict = @{
        NSForegroundColorAttributeName : [UIColor grayColor],
        NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
    };
    NSAttributedString *attStr =
            [[NSMutableAttributedString alloc] initWithString:JXUIString(@"check message")
                                                   attributes:attDict];

    [tipView addAttributedString:attStr withTarget:self andAction:@selector(openMsgBox)];
    tipView.identify = @"msgbox";
    tipView.showCloseBtn = YES;
}

// 重写父类发送文本消息方法
- (void)sendTextMessage:(NSString *)text {
    // 发送文字消息前发送取消输入消息
    if (self.workgroup.status == JXMCSUserStatusInService &&
        [JXAppConfig sharedInstance].prepareFlag) {
        [self sendForeseeMessage:nil];
    }

    [super sendTextMessage:text];
}

// 打开消息盒子
- (void)openMsgBox {
    JXMsgBoxViewController *msgBoxVC = [[JXMsgBoxViewController alloc] init];
    [self.navigationController pushViewController:msgBoxVC animated:YES];
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

#pragma mark - JXChatViewControllerDelegate

// 发送失败按钮点击事件
- (void)statusButtonSelcted:(JXMessage *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:JXUIString(@"resend message title")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:JXUIString(@"no")
                                              otherButtonTitles:JXUIString(@"yes"), nil];
    alertView.tag = resendMessageTag;
    self.resendMessage = message;
    [alertView show];
}

- (CGFloat)chatViewController:(JXChatViewController *)sender
             heightForMessage:(JXMessage *)message
                    withWidth:(CGFloat)cellWidth {
    if (message.type == JXMessageTypeEvaluation) {
        return [JXEvalMessageCell cellHeightForMessage:message];
    }
    return 0;
}

- (UITableViewCell *)chatViewController:(JXChatViewController *)sender
                         cellForMessage:(JXMessage *)message {
    if (message.type == JXMessageTypeEvaluation) {
        static NSString *evalCellID = @"JXEvalMessageCell";
        JXEvalMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:evalCellID];
        if (!cell) {
            cell = [[JXEvalMessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:evalCellID
                                                    message:message];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        // HACK: HARD CODE to fix localization issue
        [message setTextContent:JXUIString(@"evaluation message")];
        [message setCustomMessageType:JXMessageTypeEvaluation];
        cell.message = message;
        return cell;
    }
    return nil;
}

- (void)messageCellSelected:(JXMessage *)message {
    [super messageCellSelected:message];
    if (message.type == JXMessageTypeEvaluation) {
        if (self.isRobot) {
            return;
        }
        self.evaluationRequest = message;
        [self showCommandView:YES];
    }
}

// 自定义消息头像，昵称 等
- (void)chatViewController:(JXChatViewController *)sender loadingMessage:(JXMessage *)message {
    [self.tableView.mj_header endRefreshing];
    if (message.type == JXMessageTypeTips) return;
    if (message.isSender) {
        message.avatarImage = JXChatImage(@"head_sender");
    } else {
        UIImage *avatarImage = [JXMCSUserManager sharedInstance].config.avatorImage;
        message.avatarImage = avatarImage;
        if (message.isRobot) {
            message.nickname = JXUIString(@"robot name");
        } else if (message.extData[@"isSystem"] || message.extData[@"type"]) {
            message.nickname = JXUIString(@"system name");
            if (message.type == JXMessageTypeText &&
                [message.extData[@"type"] isEqualToString:@"E"] &&
                [message.textToDisplay hasPrefix:@"您好，由于长时间"]) {
                // HACK: HARD CODE to fix localization issue
                [message setTextContent:JXUIString(@"system end session")];
            }
        } else {
            //message.nickname = _workgroup.serviceNickname;
            message.nickname = message.sender;
        }
        JXAppConfig *appConfig = [JXAppConfig sharedInstance];
        message.avatarImage =
                appConfig.agentIconImage ? appConfig.agentIconImage : JXChatImage(@"head_receiver");
    }
}

#pragma mark - JXMCSManagerDelegate - JXClientDelegate

// 服务状态改变
- (void)didServiceStatusUpdated:(JXWorkgroup *)workgroup {
    JXMCSUserStatus status = workgroup.status;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHUD];
        [self setupChangeCSBtnWithInService:NO andIsHidden:NO];
        [self setupToolbarItemsWithStatus:workgroup.status];

        self.changeCSBtn.userInteractionEnabled = YES;
        self.isRobot = NO;
        self.hasEvaluated = NO;

        BOOL showTip = NO;
        BOOL hideToolbar = NO;

        switch (status) {
            case JXMCSUserStatusInRobot: {
                hideToolbar = NO;
                self.isRobot = YES;
                self.hasRobot = YES;
                if (workgroup.serviceNickname) {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                } else {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:JXUIString(@"robot title")];
                }
            } break;
            case JXMCSUserStatusAgentOffline: {
                hideToolbar = YES;
                [self setupChangeCSBtnWithInService:YES andIsHidden:NO];
                if ([JXMCSUserManager sharedInstance].isInService) {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                } else {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.displayName];
                }
                [JXMCSUserManager sharedInstance].isInService = NO;
                return;
            } break;
            case JXMCSUserStatusWaiting: {
                hideToolbar = NO;
                showTip = YES;
                [_changeCSBtn setHidden:YES];
                if (![JXMCSUserManager sharedInstance].isInService) {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.displayName];
                } else {
                    [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                }
                [JXMCSUserManager sharedInstance].isInService = NO;
                return;
            } break;
            case JXMCSUserStatusInService: {
                hideToolbar = NO;

                [self setupTitleViewWithOnlineStatus:YES andTitle:workgroup.serviceNickname];
                [self setupChangeCSBtnWithInService:YES andIsHidden:NO];
                if (![JXMCSUserManager sharedInstance].isInService &&
                    ![self.serviceNickname isEqualToString:workgroup.serviceNickname]) {
                    self.serviceNickname = workgroup.serviceNickname;
                    self.hasAgentTips = NO;
                }
                if (!self.hasAgentTips) {
                    [self addTempMessage:[NSString stringWithFormat:JXUIString(@"agent ready tips"),
                                          workgroup.serviceNickname]];
                    self.hasAgentTips = YES;
                }
                if ([JXMCSUserManager sharedInstance].config.goodsInfo) {
                    id<JXGoodsInfoModel> model = [JXMCSUserManager sharedInstance].config.goodsInfo;
                    [self sendRichMessageWithImage:model.image
                                              title:model.title
                                            content:model.content
                                                url:model.url];
                    [JXMCSUserManager sharedInstance].config.goodsInfo = nil;
                }
                
                [JXMCSUserManager sharedInstance].isInService = YES;

            } break;
            case JXMCSUserStatusInRecall: {
                hideToolbar = NO;
                [self.messageToolbar setHidden:NO];
            } break;
            case JXMCSUserStatusEnd: {
                hideToolbar = YES;
            } break;
            default:
                break;
        }

        self.showTipView = showTip;
        self.messageToolbar.hidden = hideToolbar;
    });
}

// 服务结束
- (void)didServiceEnd:(JXWorkgroup *)workgroup withError:(JXError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        JXErrorType type = error.errorCode;
        self.serviceNickname = workgroup.displayName;
        [JXMCSUserManager sharedInstance].isInService = NO;
        [self hideHUD];
        switch (type) {
            case JXErrorTypeMcsInvalidAccess:
            case JXErrorTypeMcsSkillsIdNotExist: {
                [sJXHUD showMessage:[error getLocalDescription] duration:1.0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   [self popSelf];
                               });

            } break;
            case JXErrorTypeMcsNotInService: {
                UIAlertView *alertView =
                        [[UIAlertView alloc] initWithTitle:nil
                                                   message:JXUIString(@"no agent online tips")
                                                  delegate:self
                                         cancelButtonTitle:JXUIString(@"exit")
                                         otherButtonTitles:JXUIString(@"leave message"), nil];
                alertView.tag = transRobotTag;
                [alertView show];
            } break;
            case JXErrorTypeMcsNotInServiceWithRobot: {
                UIAlertView *alertView =
                        [[UIAlertView alloc] initWithTitle:nil
                                                   message:JXUIString(@"no agent online tips")
                                                  delegate:self
                                         cancelButtonTitle:JXUIString(@"exit")
                                         otherButtonTitles:JXUIString(@"leave message"),
                                                           JXUIString(@"switch to robot"), nil];
                alertView.tag = transRobotTag;
                [alertView show];

            } break;
            case JXErrorTypeMcsChatTimeout: {
                [self setupChangeCSBtnWithInService:NO andIsHidden:YES];
            }
            case JXErrorTypeMcsDestorySessionSuccess: {
                [self addTipsMessage:JXUIString(@"session ended tips")];
                [self.messageToolbar setHidden:YES];
                [self setupTitleViewWithOnlineStatus:NO andTitle:workgroup.serviceNickname];
                [self.view endEditing:YES];
            } break;
            case JXErrorTypeMcsCancelWait: {
                [sJXHUD showMessage:JXUIString(@"cancel waiting") duration:1.0 inView:self.view];
                if (self.hasRobot) {
                    [sClient.mcsManager requestCustomerService:self.workgroup];
                    self.hasRobot = NO;
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            } break;
            case JXErrorTypeMcsLeaveQueue: {
                [sJXHUD showMessage:JXUIString(@"agent busy") duration:1.0];
                if (self.hasRobot) {
                    [sClient.mcsManager requestCustomerService:self.workgroup];
                    self.hasRobot = NO;
                } else {
                    self.messageToolbar.hidden = YES;
                }

            } break;
            case JXErrorTypeMcsAgentOffWork: {
                JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
                [message setTextContent:error.errorDescription];
                message.extData[@"isSystem"] = @(1);
                message.direction = JXMessageDirectionReceive;
                [self addMessage:message];
                UIAlertView *alertView =
                        [[UIAlertView alloc] initWithTitle:nil
                                                   message:JXUIString(@"no agent online tips")
                                                  delegate:self
                                         cancelButtonTitle:JXUIString(@"exit")
                                         otherButtonTitles:JXUIString(@"leave message"),
                                                           JXUIString(@"switch to robot"), nil];
                alertView.tag = transRobotTag;
                [alertView show];
                self.isRobot = YES;
            } break;
            case JXErrorTypeMcsRequestTimeout: {
                if (self.hasRobot) {
                    [sClient.mcsManager requestCustomerService:self.workgroup];
                    self.hasRobot = NO;
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                                       [self popSelf];
                                   });
                }
            } break;
            case JXErrorTypeMcsJoinQueueForbidden : {
                UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:nil
                                           message:JXUIString(@"join queue forbidden")
                                          delegate:self
                                 cancelButtonTitle:JXUIString(@"exit")
                                 otherButtonTitles:JXUIString(@"leave message"), nil];
                alertView.tag = transRobotTag;
                [alertView show];
                self.isRobot = YES;
            }
            default:
                break;
        }
    });
}

// 等待队列的状态更新
- (void)didService:(JXWorkgroup *)workgroup positionChanged:(NSInteger)position {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHUD];
        if (position < 1) {
            return;
        }
        
        NSString *content = [JXUIString(@"waiting position tips") stringByAppendingFormat:@"%zd", position];
        NSString *subContent = JXUIString(@"abandon access tips");
        NSMutableAttributedString *cancelString =
                [[NSMutableAttributedString alloc] initWithString:JXUIString(@"cancel")];
        NSMutableAttributedString *leaveString =
                [[NSMutableAttributedString alloc] initWithString:JXUIString(@"leave message")];

        [cancelString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor grayColor]
                             range:NSMakeRange(0, cancelString.length)];
        [leaveString addAttribute:NSForegroundColorAttributeName
                            value:[UIColor grayColor]
                            range:NSMakeRange(0, leaveString.length)];
        [cancelString addAttribute:NSUnderlineStyleAttributeName
                             value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                             range:NSMakeRange(0, cancelString.length)];
        [leaveString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                            range:NSMakeRange(0, leaveString.length)];

        JXTipView *tipView = self.tipView;
        tipView.identify = @"service";
        tipView.showCloseBtn = NO;
        tipView.contentString = content;
        self.subTipView.contentString = subContent;
        if (self.showTipView == NO) {
            [self.subTipView addAttributedString:cancelString
                              withTarget:sClient.mcsManager
                               andAction:@selector(cancelWait)];
            [self.subTipView addAttributedString:leaveString
                              withTarget:self
                               andAction:@selector(leaveMessageOnline)];
        }
        self.showTipView = YES;
        self.showSubTipeView = YES;
    });
}

// 收到评价请求
- (void)didReceiveEvaluationRequest:(JXWorkgroup *)workgroup {
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    message.direction = JXMessageDirectionReceive;
    // 判断是否显示邀请语
    JXMcsEvaluation *evaluation = [JXMCSUserManager sharedInstance].evaluation;
    NSString *judgeText = evaluation.satisfyInviteFlag ? evaluation.title : @"";

    [message setTextContent:judgeText];
    [message setCustomMessageType:JXMessageTypeEvaluation];
    message.extData[@"isSystem"] = @(1);

    [self addMessage:message];
}

#pragma mark - JXMessageToolbarDelegate

// 输入框内值改变
- (void)inputTextViewDidValueChange:(JXMessageTextView *)inputTextView {
    if ([JXAppConfig sharedInstance].prepareFlag == 0) return;
    if (self.workgroup.status != JXMCSUserStatusInService) return;

    if (inputTextView.text.length <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self sendForeseeMessage:nil];
    } else {
        [self.timer fire];
    }
}

#pragma mark - JXCommandViewDelegate

/**
 完成满意度评价回调
 */
- (void)didfinishedCommandWithScore:(int)score {
    WEAKSELF;
    dispatch_block_t block = ^{
        [sJXHUD showMessageWithActivityIndicatorView:JXUIString(@"loading")];
        [sClient.mcsManager
                evaluateService:weakSelf.workgroup
                       andScore:score
                    andCallback:^(JXError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [sJXHUD hideHUD];
                            if (error) return;
                            if ([JXMCSUserManager sharedInstance].evaluation.satisfyThanksFlag) {
                                [weakSelf addTempMessage:[JXMCSUserManager sharedInstance]
                                                                 .evaluation.thanksMsg];
                            }
                            [weakSelf.commandView hideView];
                            [weakSelf removeMessage:weakSelf.evaluationRequest];
                            weakSelf.hasEvaluated = YES;
                        });
                    }];
    };
    self.submitReviewBlock = block;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:JXUIString(@"evaluation")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:JXUIString(@"cancel")
                                              otherButtonTitles:JXUIString(@"ok"), nil];
    alertView.tag = submitReviewTag;
    [alertView show];
}

- (void)didSelectedQuestion:(NSString *)question {
    self.messageToolbar.inputTextView.text = question;
    [self.messageToolbar.inputTextView becomeFirstResponder];
    [_commandView hideView];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == transAgentTypeTag) {
        if (buttonIndex == 1) {
            self.showTipView = NO;
            [sClient.mcsManager transferCustomerService];
        }
    } else if (alertView.tag == resendMessageTag) {
        if (buttonIndex == 1) {
            [self resendMessage:self.resendMessage];
        }
    } else if (alertView.tag == transRobotTag) {
        if (buttonIndex == 0) {
            [self popSelf];
        } else if (buttonIndex == 1) {
            [self leaveMessageOnline];
            if (!self.hasRobot) {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
    } else if (alertView.tag == submitReviewTag) {
        if (buttonIndex == 1) {
            self.submitReviewBlock();
        }
    } else if (alertView.tag == endSessionTag) {
        if (buttonIndex == 1) {
            [sClient.mcsManager leaveService];
        }
    }
}

#pragma mark - getter

- (NSTimer *)timer {
    if (!_timer) {
        WEAKSELF;
        _timer = [NSTimer
                scheduledTimerWithTimeInterval:1.f
                                         block:^{
                                             if (weakSelf.messageToolbar.text.length &&
                                                 ![weakSelf.messageToolbar.text
                                                         isEqualToString:
                                                                 weakSelf.lastForeseeText]) {
                                                 weakSelf.lastForeseeText =
                                                         weakSelf.messageToolbar.text;
                                                 [weakSelf sendForeseeMessage:
                                                                   weakSelf.lastForeseeText];
                                             }
                                         }
                                       repeats:YES];
    }
    return _timer;
}

// 当前队列提示view
- (JXTipView *)tipView {
    if (_tipView == nil) {
        _tipView = [[JXTipView alloc] init];
        _tipView.frame = CGRectMake(0, 0, self.view.jx_width, 30);
        WEAKSELF;
        [_tipView setClosedComplete:^(JXTipView *tipview) {
            weakSelf.showTipView = NO;
        }];
    }
    return _tipView;
}

- (JXTipView *)subTipView {
    if (!_subTipView) {
        _subTipView = [[JXTipView alloc] init];
        _subTipView.frame = CGRectMake(0, 30, self.view.jx_width, 30);
        _subTipView.showCloseBtn = NO;
    }
    return _subTipView;
}

@end
