//
//  JXChatViewController.m
//

#import "JXChatViewController.h"

#import "JXChatViewController+Chatroom.h"
#import "JXChatViewController+MessageSend.h"
#import "JXChatViewController+Toolbar.h"
#import "JXImageViewController.h"

#import "JXMessageFileDownloader.h"
#import "JXReminder.h"
#import "JXVideoViewController.h"
#import "JXVoiceMessagePlayer.h"
#import "JXWebViewController.h"

#import "JXShowView.h"

#import <objc/objc.h>

#define kMinTimeSpace 60

@interface JXChatViewController ()<JXShowViewDelegate, UIDocumentInteractionControllerDelegate> {
    dispatch_queue_t _messageQueue;
}

@end

@implementation JXChatViewController

+ (void)initialize {
    // Custom UI
    [[JXMessageCell appearance]
            setSendBubbleBackgroundImage:[JXChatImage(@"bubbles_sender")
                                                 stretchableImageWithLeftCapWidth:20
                                                                     topCapHeight:24]];
    [[JXMessageCell appearance]
            setRecvBubbleBackgroundImage:[JXChatImage(@"bubbles_reciever")
                                                 stretchableImageWithLeftCapWidth:20
                                                                     topCapHeight:24]];
}

- (instancetype)initWithConversation:(JXConversation *)conversation {
    return [self initWithChatter:conversation.chatter andChatType:conversation.type];
}

- (instancetype)initWithChatter:(NSString *)chatter andChatType:(JXChatType)chatType {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        _conversation = [sClient.chatManager conversationForChatter:chatter andType:chatType];
        if (!_conversation) return nil;

        _lastMessageTimestamp = -1;
        _messageCountOfPage = 20;
        _timeCellHeight = 30;
        _dataSource = [NSMutableArray array];
        _allowEmojiChat = YES;
        _allowVoiceChat = YES;
        _delegate = self;
        [_conversation resetUnRead];
        self.title = _conversation.subject;
        _messageQueue = dispatch_get_main_queue();
        // TODO: move to other thread
    }
    return self;
}

- (BOOL)isMessageInConversation:(JXMessage *)message {
    return (message.chatType == _conversation.type &&
            [message.conversationChatter isEqualToString:_conversation.chatter]);
}

- (void)setupListener {
    [sClient addDelegate:self];
    [sVoiceMessagePlayer addVoiceMessagePlayerObsever:self];
    [JXMessageFileDownloader addDownloadStatusObserver:self];
    if ([self respondsToSelector:@selector(joinChatroom)]) {
        [self joinChatroom];
    }
}

- (void)removeListener {
    if ([self respondsToSelector:@selector(leaveChatroom)]) {
        [self leaveChatroom];
    }
    [sClient removeDelegate:self];
    [JXMessageFileDownloader removeDownloadStatusObserver:self];
    [sVoiceMessagePlayer removeVoiceMessagePlayerObsever:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:self.class] && vc != self) {
            [self popSelfWithoutAnimation];
            return;
        }
    }

    [self.view setBackgroundColor:JXPureColor(245)];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.messageToolbar];
    self.tableView.estimatedRowHeight = 0;

    WEAKSELF;
    //    [self.tableView setTapActionWithBlock:^{
    //        [weakSelf.messageToolbar endEditing:YES];
    //    }];
    [self.tableView setLongPressActionWithBlock:^(UIGestureRecognizer *gesture) {
        [weakSelf handleLongPress:gesture];
    }];

    SEL mj_selector = NSSelectorFromString(@"setMj_header:");
    if ([self.tableView respondsToSelector:mj_selector]) {
        Class MJNormalHeader = NSClassFromString(@"MJRefreshNormalHeader");
        SEL createHeader = NSSelectorFromString(@"headerWithRefreshingBlock:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id normalHeader = [MJNormalHeader
                performSelector:createHeader
                     withObject:^{
                         JXMessage *message;
                         for (id msg in weakSelf.dataSource) {
                             if ([msg isKindOfClass:[JXMessage class]]) {
                                 message = msg;
                                 break;
                             }
                         }
                         [weakSelf loadMessagesBefore:message];
                         [[weakSelf.tableView valueForKey:@"mj_header"] endRefreshing];
                     }];
        [self.tableView performSelector:mj_selector withObject:normalHeader];
#pragma clang diagnostic pop
    }

    [self setupDefaultLeftButtonItem];
    [self setupListener];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self.view setInsetsLayoutMarginsFromSafeArea:YES];
}

- (void)viewDidPop {
    [super viewDidPop];
    [[JXVoiceMessagePlayer sharedInstance] stopPlayAudio];
    [self.voiceRecorder cancelCurrentRecord];
    [self removeListener];
    [_conversation resetUnRead];
    [self hideHUD];
}

#pragma mark - menu

- (void)handleLongPress:(UIGestureRecognizer *)gesture {
    if (![self.dataSource count]) return;
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    _menuIndexPath = indexPath;

    if (_delegate &&
        [_delegate respondsToSelector:@selector(chatViewController:didLongPressRowAtIndexPath:)]) {
        [self.delegate chatViewController:self didLongPressRowAtIndexPath:indexPath];
    } else {
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if (![object isKindOfClass:[NSString class]]) {
            JXCommonMessageCell *cell =
                    (JXCommonMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            [self showMenuViewController:cell andMessage:object];
        }
    }
}

- (void)showMenuViewController:(JXCommonMessageCell *)showInView andMessage:(JXMessage *)message {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSArray *items = [self editMenuItemsForMessage:message];
    if ([items count] > 0) {
        [self becomeFirstResponder];
        [menu setMenuItems:items];
        CGRect targetRect = CGRectMake(showInView.bubbleView.jx_origin.x, showInView.jx_origin.y,
                                       showInView.bubbleView.jx_width, showInView.jx_height);
        [menu setTargetRect:targetRect inView:showInView.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (NSArray *)editMenuItemsForMessage:(JXMessage *)message {
    UIMenuItem *delete =
            [[UIMenuItem alloc] initWithTitle:JXUIString(@"delete") action:@selector(deleteCell:)];
    UIMenuItem *copy =
            [[UIMenuItem alloc] initWithTitle:JXUIString(@"copy") action:@selector(copyCell:)];
    NSArray *items = nil;
    if ([self.delegate respondsToSelector:@selector(chatViewController:menuItemsAdd2DefaultMenu:)]) {
        items = [self.delegate chatViewController:self menuItemsAdd2DefaultMenu:message];
    }
    NSMutableArray *ret = [NSMutableArray array];
    if (message.type == JXMessageTypeText) {
        [ret addObjectsFromArray:@[delete, copy]];
    } else {
        [ret addObject:delete];
    }
    [ret addObjectsFromArray:items];
    return ret;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyCell:)) {
        return YES;
    }
    if (action == @selector(deleteCell:)) {
        return YES;
    }
    if (action == @selector(mutipleSelect:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)copyCell:(id)sender {
    id message = [self.dataSource objectAtIndex:self.menuIndexPath.row];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if ([message isKindOfClass:[JXMessage class]]) {
        [pasteboard setString:[(JXMessage *)message textToDisplay]];
    } else if ([message isKindOfClass:[NSString class]]) {
        [pasteboard setString:message];
    }
    
}

- (void)mutipleSelect:(id)sender {
    JXLog(@"MessageActive TypeMutipleSelect");
}

- (void)deleteCell:(id)sender {
    JXMessage *message = [self.dataSource objectAtIndex:self.menuIndexPath.row];
    if ([self.conversation isCachedMessageId:message.messageId]) {
        [self.conversation deleteMessage:message];
    } else {
        [self removeMessage:message];
    }
}

#pragma mark - getter

- (UITableView *)tableView {
    if (_tableView) return _tableView;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - JXSafeAreaBottom - [JXMessageToolbar defaultHeight]);
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    return _tableView;
}

- (UIView *)messageToolbar {
    if (_messageToolbar) return _messageToolbar;
    
    CGFloat toolbarHeight = [JXMessageToolbar defaultHeight];
    
    _messageToolbar = [[JXMessageToolbar alloc]
            initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame),
                                     self.view.frame.size.width, toolbarHeight)];
    [(JXMessageToolbar *)_messageToolbar setDelegate:self];
    _messageToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    return _messageToolbar;
}

#pragma mark - load data

- (void)insertHistoryMessages:(NSArray *)loading refresh:(BOOL)refresh {
    if (!loading.count) {
        return;
    }
    self.lastMessageTimestamp = -1;
    NSUInteger count = self.dataSource.count;
    loading = [self organizeMessages:loading];
    if (!refresh) {
        NSIndexSet *indexSet =
                [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, loading.count)];
        [self.dataSource insertObjects:loading atIndexes:indexSet];
    } else {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:loading];
    }
    [self reloadMessageIndex];
    [self.tableView reloadData];
    if (refresh) {
        [self.tableView scrollToBottomWithAnimation:NO];
    } else {
        NSIndexPath *indexPath =
                [NSIndexPath indexPathForRow:self.dataSource.count - count inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
}

- (void)loadMessagesBefore:(JXMessage *)message {
    WEAKSELF;
    dispatch_async(_messageQueue, ^{
        if (!weakSelf.messageCountOfPage) {
            return;
        }
        NSArray *loading = [weakSelf.conversation loadMessagesBefore:message
                                                               count:weakSelf.messageCountOfPage];
        BOOL refresh = message ? NO : YES;
        [weakSelf insertHistoryMessages:loading refresh:refresh];
    });
}

- (void)reloadMessageIndex {
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[JXMessage class]]) {
            [obj setIndexInTableView:idx];
            self.lastMessageTimestamp = [(JXMessage *)obj timestamp];
        }
    }];
}

- (NSArray *)organizeMessages:(NSArray *)messages {
    if (!messages.count) return @[];
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    for (JXMessage *message in messages) {
        if (_lastMessageTimestamp < 0 ||
            message.timestamp - _lastMessageTimestamp >= kMinTimeSpace) {
            NSString *timeStr = [NSDate formattedTimeFromTimeInterval:message.timestamp];
            [formattedArray addObject:timeStr];
            _lastMessageTimestamp = message.timestamp;
        }
        if (_delegate &&
            [_delegate respondsToSelector:@selector(chatViewController:loadingMessage:)]) {
            [_delegate chatViewController:self loadingMessage:message];
        } else {
            message.avatarImage = JXChatImage(@"icon");
        }
        [formattedArray addObject:message];
    }
    return formattedArray;
}

- (void)addMessage:(JXMessage *)message {
    if (!message) return;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [self organizeMessages:@[ message ]];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messages.count];
        for (id obj in messages) {
            [self.dataSource addObject:obj];
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.dataSource.count - 1
                                                     inSection:0]];
        }
        NSInteger messageIndex = self.dataSource.count - 1;
        message.indexInTableView = messageIndex;
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView scrollToRowAtIndexPath:indexPaths.lastObject
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];        
    });
}

- (void)removeMessage:(JXMessage *)message {
    NSIndexPath *indexPath = [self indexPathForMessage:message];
    message.indexInTableView = -1;
    if (!indexPath) return;

    WEAKSELF;
    dispatch_async(_messageQueue, ^{
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:indexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:indexPath, nil];
        if (indexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [weakSelf.dataSource objectAtIndex:(indexPath.row - 1)];
            if (indexPath.row + 1 < [weakSelf.dataSource count]) {
                nextMessage = [weakSelf.dataSource objectAtIndex:(indexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) &&
                [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:indexPath.row - 1];
                [indexPaths
                        addObject:[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:0]];
            }
        }
        [weakSelf.dataSource removeObjectsAtIndexes:indexs];
        JXMessage *latest = [weakSelf.dataSource lastObject];
        weakSelf.lastMessageTimestamp = latest.timestamp;
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView deleteRowsAtIndexPaths:indexPaths
                                  withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf.tableView endUpdates];
        [weakSelf reloadMessageIndex];
    });
}

#pragma mark - Table view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.messageToolbar endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_dataSource objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        return self.timeCellHeight;
    }
    JXMessage *message = object;
    if (_delegate &&
        [_delegate respondsToSelector:@selector(chatViewController:heightForMessage:withWidth:)]) {
        CGFloat height = [_delegate chatViewController:self
                                      heightForMessage:message
                                             withWidth:tableView.frame.size.width];
        if (height > 0) return height;
    }
    return [JXCommonMessageCell cellHeightForMessage:message];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_dataSource objectAtIndex:indexPath.row];
    return (![object isKindOfClass:[NSString class]]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //     JXCommonMessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //     JXMessage *message = cell.message;
    //    [self.editSelectedMessages addObject:message];
    //    [self.moreEditOperView allowActive:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // JXCommonMessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // JXMessage *message = [self messageForIndexPath:indexPath];
    //[self.editSelectedMessages removeObject:message];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_dataSource objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *timeCellIdentifier = [JXMessageTimeCell cellIdentifier];
        JXMessageTimeCell *timeCell = (JXMessageTimeCell *)[tableView
                dequeueReusableCellWithIdentifier:timeCellIdentifier];
        if (timeCell == nil) {
            timeCell = [[JXMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:timeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            timeCell.userInteractionEnabled = NO;
            timeCell.titleLabelBkgColor = JXColorWithRGB(228, 228, 228);
            timeCell.titleLabelColor = JXColorWithRGB(183, 183, 183);
        }
        timeCell.title = object;
        return timeCell;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(chatViewController:cellForMessage:)]) {
        UITableViewCell *cell = [_delegate chatViewController:self cellForMessage:object];
        if (cell) {
            if ([cell isKindOfClass:[JXMessageCell class]]) {
                JXMessageCell *msgCell = (JXMessageCell *)cell;
                if (!msgCell.delegate) msgCell.delegate = self;
            }
            return cell;
        }
    }

    NSString *cellIdentifier = [JXMessageCell cellIdentifierForMessage:object];
    JXCommonMessageCell *msgCell =
            (JXCommonMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!msgCell) {
        msgCell = [[JXCommonMessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:cellIdentifier
                                                     message:object];
        msgCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        msgCell.avatarCornerRadius = 0;
        msgCell.delegate = self;
    }
    if (msgCell.message != object) {
        msgCell.message = object;
    } else {
        [msgCell updateMessageStatus];
    }
    return msgCell;
}

#pragma mark - private method

- (NSIndexPath *)indexPathForMessage:(JXMessage *)message {
    if (!message || message.indexInTableView < 0) return nil;
    return [NSIndexPath indexPathForRow:message.indexInTableView inSection:0];
}

- (JXMessageCell *)cellForMessage:(JXMessage *)message {
    NSIndexPath *indexPath = [self indexPathForMessage:message];
    if (!indexPath) return nil;
    return (JXMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)reloadCellForMessage:(JXMessage *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self indexPathForMessage:message];
        if (!indexPath) return;
            // Fallback on earlier versions
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                              withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)loadDocument:(NSString *)documentPath name:(NSString *)name {
    [self hideHUD];
    UIDocumentInteractionController *doc= [UIDocumentInteractionController
                                           interactionControllerWithURL:[NSURL fileURLWithPath:documentPath]];
    doc.name = name;
    doc.delegate = self;
    [doc presentPreviewAnimated:YES];
}

#pragma mark - JXVoiceMessagePlayerDelegate

- (void)stopCellAudioPlayAnimationWithMessageID:(NSString *)messageID {
    if (![_conversation isCachedMessageId:messageID]) return;
    JXMessage *message = [_conversation messageForId:messageID];
    message.isMediaPlaying = NO;
    [self reloadCellForMessage:message];
}

- (void)audioFilePlayFinishedWithMessageID:(NSString *)messageID {
    [self stopCellAudioPlayAnimationWithMessageID:messageID];
}

- (void)audioFilePlayFailedWithMessageID:(NSString *)messageID error:(NSString *)error {
    [self stopCellAudioPlayAnimationWithMessageID:messageID];
    [sJXHUD showMessage:[NSString stringWithFormat:@"%@", error] duration:1.2];
}

#pragma mark - JXMessageFileDownloaderDelegate

- (void)didMessage:(NSString *)messageID updateProgress:(float)progress {
    if (![_conversation isCachedMessageId:messageID]) return;
    JXMessage *message = [_conversation messageForId:messageID];
    message.progress = progress;
    JXMessageCell *cell = [self cellForMessage:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell updateMessageStatus];
    });
    // 若调用该方法会阻塞线程
    //    [self reloadCellForMessage:message];
}

- (void)messageFileDownloadSuccesed:(NSString *)messageID {
    if (![_conversation isCachedMessageId:messageID]) return;
    JXMessage *message = [_conversation messageForId:messageID];
    message.progress = 1.0;

    [self reloadCellForMessage:message];
}

- (void)messageFileDownloadFailed:(NSString *)messageID {
    if (![_conversation isCachedMessageId:messageID]) return;
    JXMessage *message = [_conversation messageForId:messageID];
    message.progress = -1;
    [sJXHUD showMessage:JXUIString(@"fail to download") duration:0.8];

    [self reloadCellForMessage:message];
}

#pragma mark - JXChatManagerDelegate

- (void)didRemoveMessage:(JXMessage *)message {
    if ([self isMessageInConversation:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeMessage:message];
        });
    }
}

- (void)didReceiveMessage:(JXMessage *)message {
    if ([self isMessageInConversation:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (message.type == JXMessageTypeText) {
                message.isRead = YES;
            }
            [self addMessage:message];
        });
    }
}

- (void)didInsertMessage:(JXMessage *)message {
    if ([self isMessageInConversation:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addMessage:message];
        });
    }
}

- (void)didMessageStatusChanged:(JXMessage *)message {
    JXMessageStatus status = message.status;
    if ([self isMessageInConversation:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == JXMessageStatusDownload) {
                message.cellHeight = 0;
            } else if (status == JXMessageStatusSend) {
                message.progress = 1;
            }
            [self reloadCellForMessage:message];
        });
    }
}

- (void)didMessageUploadStatusChanged:(JXMessage *)message progress:(float)progress {
    if ([self isMessageInConversation:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            message.progress = progress;
            [self reloadCellForMessage:message];
        });
    }
}

#pragma mark - JXMessageCellDelegate

- (void)richMessageCellSelected:(JXMessage *)message isImage:(BOOL)isImage {
    if (isImage) {
        JXImageViewController *reviewVC = [[JXImageViewController alloc] initWithMessage:message];
        [self.navigationController pushViewController:reviewVC animated:YES];
    } else {
        if (message.isSender) {
            [self sendTextMessage:message.linkURL];
//            JXWebViewController *netViewController = [[JXWebViewController alloc] init];
//            netViewController.netString = message.linkURL;
//            [self.navigationController pushViewController:netViewController animated:YES];
        } else {
            JXWebViewController *netViewController = [[JXWebViewController alloc] init];
            netViewController.netString = message.linkURL;
            [self.navigationController pushViewController:netViewController animated:YES];
        }
    }
}

- (void)messageCellSelected:(JXMessage *)message {
    JXMessageCell *cell = [self cellForMessage:message];
    
    if (![cell isKindOfClass:[JXMessageCell class]]) return;

    if ([cell isCustomBubbleView:message]) {
        // callback here
        return;
    }

    switch (message.type) {
        case JXMessageTypeText:
            [self textMessageCellSelected:message];
            break;
        case JXMessageTypeImage: {
            message.isRead = YES;
            JXImageViewController *reviewVC =
                    [[JXImageViewController alloc] initWithMessage:message];
            [self.navigationController pushViewController:reviewVC animated:YES];
        } break;
        case JXMessageTypeLocation: {
            message.isRead = YES;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:message.latitude
                                                              longitude:message.longitude];
            JXLocationViewController *positionVC =
                    [[JXLocationViewController alloc] initWithLoction:location];
            positionVC.locationDescribe = message.label;
            UINavigationController *nav =
                    [[UINavigationController alloc] initWithRootViewController:positionVC];
            [self presentViewController:nav animated:YES completion:nil];

        } break;
        case JXMessageTypeAudio: {
            JXVoiceMessagePlayer *voicePlayer = [JXVoiceMessagePlayer sharedInstance];
            [voicePlayer playAudioWithFilePath:message.localURL messageID:message.messageId];
            message.isRead = YES;
        } break;
        case JXMessageTypeFile: {
            
            NSData *data = [NSData dataWithContentsOfFile:message.localURL];
            if ([data length] != message.fileSize) {
                return;
            }
            [self loadDocument:message.localURL name:message.fileName];
//            UIActivityViewController *controller =
//                    [[UIActivityViewController alloc] initWithActivityItems:@[ data ]
//                                                      applicationActivities:nil];
//            [self presentViewController:controller animated:YES completion:nil];
            
        } break;
        case JXMessageTypeVideo: {
            JXVideoViewController *videoVC =
                    [[JXVideoViewController alloc] initWithMessage:message];
            [self presentViewController:videoVC animated:YES completion:nil];
        } break;
        default:
            break;
    }
}

- (void)textMessageCellSelected:(JXMessage *)message {
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
                                                              delegate:self
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

- (void)messageCell:(JXMessageCell *)cell fileMessageIconViewSelected:(JXMessage *)message {
    NSData *data = [NSData dataWithContentsOfFile:message.localURL];
    if ([data length] < message.fileSize) {
        NSTimeInterval date = [[NSDate date] timeIntervalSince1970] * 1000;
        if (date < message.expiredTime) {
            [JXMessageFileDownloader downloadFileForMessage:message];
        } else {
            [sJXHUD showMessage:JXUIString(@"file timeout tips") duration:0.8];
        }
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    
    return self;
}

- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {
    
    return self.tableView;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {
    
    return CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",
                                                                        actionSheet.title]]];
    }
}

#pragma mark - JXShowViewDelegate
- (void)didSelectedUrlString:(NSString *)urlString {
    JXWebViewController *netViewController = [[JXWebViewController alloc] init];
    netViewController.netString = urlString;
    [self.navigationController pushViewController:netViewController animated:YES];
}

@end
