//
//  JXMsgBoxViewController.m
//  mcs_demo
//
//  Created by raymond on 16/11/8.
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import "JXMsgBoxViewController.h"
#import "JXAppConfig+Extends.h"
#import "JXMCSUserManager.h"
#import "JXMessageTimeCell.h"
#import "JXMsgBoxCell.h"
#import "JXShowView.h"
#import "JXWebViewController.h"
#import "MJRefresh.h"

#define MsgBoxCellReuseId @"MsgBoxCellReuseId"

@interface JXMsgBoxViewController ()<JXShowViewDelegate, UIActionSheetDelegate,
                                     JXMessageCellDelegate, JXClientDelegate>

@property(nonatomic, strong) NSMutableArray *messageList;
@property(nonatomic, strong) NSDateFormatter *formatter;
@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, strong) JXShowView *showView;

@end

@implementation JXMsgBoxViewController

+ (void)initialize {
    // Custom UI
    [[JXMessageCell appearance]
            setRecvBubbleBackgroundImage:[JXChatImage(@"bubbles_reciever")
                                                 stretchableImageWithLeftCapWidth:20
                                                                     topCapHeight:24]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WEAKSELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf fetchMessageWithPage:weakSelf.currentPage];
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:JXPureColor(245)];
    [self setupDefaultLeftButtonItem];
    [self.tableView.mj_header beginRefreshing];
    [sClient addDelegate:self];
    self.title = JXUIString(@"message center");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidPop {
    [super viewDidPop];
    [sClient removeDelegate:self];
}

- (void)fetchMessageWithPage:(NSInteger)page {
    WEAKSELF;
    NSDictionary *params = @{
        @"start" : @(page * 5),
        @"limit" : @(5),
        @"username" : [sClient.loginManager username]
    };
    [JXMCSUserManager GETWithApi:@"visitor/msgbox/getMessageList"
                          params:params
                    withCallBack:^(id response, NSInteger status, NSError *error) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView.mj_header endRefreshing];
                            if ([response[@"code"] integerValue] != 200 || error) {
                                sJXHUDMes(JXUIString(@"request failed"), 1.3);
                                return;
                            }
                            if ([response[@"list"] count]) {
                                weakSelf.currentPage++;
                            }
                            for (NSDictionary *dict in response[@"list"]) {
                                // 添加消息
                                JXMessage *message = [[JXMessage alloc]
                                        initWithSender:dict[@"agentJID"]
                                               andType:[dict[@"type"] integerValue]];
                                [message setTextContent:dict[@"content"]];
                                message.nickname = dict[@"agentName"];
                                [self.messageList insertObject:message atIndex:0];

                                // 添加时间
                                self.formatter = [[NSDateFormatter alloc] init];
                                self.formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                                NSDate *date =
                                        [self.formatter dateFromString:dict[@"creationTime"]];
                                self.formatter.dateFormat = @"MM-dd HH:mm";
                                NSString *time = [self.formatter stringFromDate:date];
                                if (time.length) [self.messageList insertObject:time atIndex:0];
                            }
                            [[JXMCSUserManager sharedInstance] setAllMessageRead];
                            [weakSelf.tableView reloadData];
                        });
                    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JXMessage *message = self.messageList[indexPath.row];
    if ([message isKindOfClass:[NSString class]]) {
        JXMessageTimeCell *cell =
                [tableView dequeueReusableCellWithIdentifier:[JXMessageTimeCell cellIdentifier]];
        if (!cell) {
            cell = [[JXMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:[JXMessageTimeCell cellIdentifier]];
        }
        cell.title = (NSString *)message;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        JXMsgBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:MsgBoxCellReuseId];
        if (!cell) {
            cell = [[JXMsgBoxCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MsgBoxCellReuseId
                                               message:message];
        }
        JXAppConfig *appConfig = [JXAppConfig sharedInstance];
        message.avatarImage =
                appConfig.agentIconImage ? appConfig.agentIconImage : JXChatImage(@"head_receiver");
        [cell setMessage:message];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JXMessage *message = self.messageList[indexPath.row];
    if ([message isKindOfClass:[NSString class]]) {
        return 30;
    }
    return [JXMsgBoxCell cellHeightForMessage:message];
}

#pragma mark - JXMessageCellDelegate

- (void)messageCellSelected:(JXMessage *)message {
    if ([message isKindOfClass:[NSString class]]) return;
    NSArray *matchs = [message urlMatches];
    NSMutableArray *resultArray = [NSMutableArray array];
    CGFloat showViewHeight = 0;
    for (NSTextCheckingResult *match in matchs) {
        if (match.resultType == NSTextCheckingTypePhoneNumber) {
            [resultArray addObject:match];
            CGFloat textHeight = [self getTextHeightWithText:match.phoneNumber];
            textHeight = textHeight > 60 ? textHeight : 60;
            showViewHeight += textHeight;

        } else if (match.resultType == NSTextCheckingTypeLink) {
            [resultArray addObject:match];
            CGFloat textHeight = [self getTextHeightWithText:match.URL.absoluteString];
            textHeight = textHeight > 60 ? textHeight : 60;
            showViewHeight += textHeight;
        }
    }

    [self.view endEditing:YES];
    if (resultArray.count) {
        if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
            JXShowView *showView =
                    [[JXShowView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                                 self.view.frame.size.height)];
            showView.message = message;
            showView.delegate = self;
            [self.view addSubview:showView];
            [self.view bringSubviewToFront:self.showView];
            [showView loadShowView];

        } else {
            UIAlertController *alertController =
                    [UIAlertController alertControllerWithTitle:JXUIString(@"please select")
                                                        message:@""
                                                 preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:JXUIString(@"cancel")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            [alertController addAction:cancelAction];
            for (NSTextCheckingResult *result in resultArray) {
                NSString *text;
                UIAlertAction *archiveAction;
                if (result.resultType == NSTextCheckingTypePhoneNumber) {
                    text = result.phoneNumber;
                    WEAKSELF;
                    archiveAction = [UIAlertAction
                            actionWithTitle:text
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *_Nonnull action) {
                                        UIActionSheet *sheet = [[UIActionSheet alloc]
                                                         initWithTitle:result.phoneNumber
                                                              delegate:weakSelf
                                                     cancelButtonTitle:JXUIString(@"cancel")
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:JXUIString(@"call"), nil];
                                        [sheet showInView:weakSelf.view];
                                    }];
                } else if (result.resultType == NSTextCheckingTypeLink) {
                    text = result.URL.absoluteString;
                    archiveAction = [UIAlertAction
                            actionWithTitle:text
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *_Nonnull action) {
                                        JXWebViewController *netViewController =
                                                [[JXWebViewController alloc] init];
                                        netViewController.netString = result.URL.absoluteString;
                                        [self.navigationController
                                                pushViewController:netViewController
                                                          animated:YES];
                                    }];
                }
                [alertController addAction:archiveAction];
            }
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (CGFloat)getTextHeightWithText:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingUsesFontLeading
                                    attributes:@{
                                        NSFontAttributeName : [UIFont systemFontOfSize:16]
                                    }
                                       context:nil]
                          .size;
    return size.height;
}

#pragma mark - JXShowViewDelegate

- (void)didSelectedUrlString:(NSString *)urlString {
    JXWebViewController *netViewController = [[JXWebViewController alloc] init];
    netViewController.netString = urlString;
    [self.navigationController pushViewController:netViewController animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",
                                                                        actionSheet.title]]];
    }
}

#pragma mark - JXClientDelegate

- (void)didReceiveAgentLeaveMessage:(NSDictionary *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 添加时间
        self.formatter = [[NSDateFormatter alloc] init];
        NSDate *date = [NSDate date];
        self.formatter.dateFormat = @"MM-dd HH:mm";
        NSString *time = [self.formatter stringFromDate:date];
        if (time.length) [self.messageList addObject:time];

        // 添加消息
        JXMessage *message =
                [[JXMessage alloc] initWithSender:info[@"AgentJID"] andType:JXChatTypeGroup];
        [message setTextContent:info[@"Content"]];
        message.nickname = info[@"NickName"];
        [self.messageList addObject:message];

        [self.tableView reloadData];
        [self.tableView scrollToBottomWithAnimation:YES];
    });
    [[JXMCSUserManager sharedInstance] setAllMessageRead];
}

#pragma mark - getter

- (NSMutableArray *)messageList {
    if (!_messageList) {
        _messageList = [NSMutableArray array];
    }
    return _messageList;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
    }
    return _formatter;
}

@end
