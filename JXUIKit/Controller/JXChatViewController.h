//
//  JXChatViewController.h
//

#import "JXBaseViewController.h"
#import "JXImageViewController.h"
#import "JXLocationViewController.h"

#import "JXCommonMessageCell.h"
#import "JXMessageTimeCell.h"
#import "JXMessageToolbar.h"

#import "JXMessageFileDownloader.h"
#import "JXVoiceMessagePlayer.h"
#import "JXVoiceMessageRecorder.h"

#import "JXActionView.h"
#import "JXSDKHelper.h"

@class JXChatViewController;

@protocol JXChatViewControllerDelegate<NSObject>

@optional

/**
 *  消息自定义cell
 */
- (UITableViewCell *)chatViewController:(JXChatViewController *)sender
                         cellForMessage:(JXMessage *)message;

/**
 *  消息cell高度
 */
- (CGFloat)chatViewController:(JXChatViewController *)sender
             heightForMessage:(JXMessage *)message
                    withWidth:(CGFloat)cellWidth;

/**
 *  加载更多消息
 */
- (NSArray *)chatViewController:(JXChatViewController *)sender
             loadMessagesBefore:(JXMessage *)message
                          count:(NSInteger)count;

/**
 *  正在加载消息
 */
- (void)chatViewController:(JXChatViewController *)sender loadingMessage:(JXMessage *)message;

/**
 *  触发长按手势
 */
- (BOOL)chatViewController:(JXChatViewController *)sender
didLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray<UIMenuItem *> *)chatViewController:(JXChatViewController *)sender
           menuItemsAdd2DefaultMenu:(JXMessage *)message;

/**
  *  底部录音功能按钮
  */
- (void)chatViewController:(JXChatViewController *)sender
       didSelectRecordView:(UIView *)recordView
              withEvenType:(JXRecordViewType)type;

@end

@interface JXChatViewController
        : JXBaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
                               JXChatViewControllerDelegate, JXMessageCellDelegate,
                               JXVoiceMessagePlayerDelegate, JXMessageFileDownloaderDelegate,
                               JXClientDelegate>

@property(nonatomic, weak) id<JXChatViewControllerDelegate> delegate;

@property(nonatomic, strong, readonly) JXConversation *conversation;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) JXMessageToolbar *messageToolbar;

@property(nonatomic, assign) NSTimeInterval lastMessageTimestamp;
@property(nonatomic, assign) NSInteger messageCountOfPage;    // default 20
@property(nonatomic, assign) CGFloat timeCellHeight;    //时间分割cell的高度 default 30

@property(nonatomic, strong) NSIndexPath *menuIndexPath;

@property(nonatomic, assign, getter=isAllowVoiceChat) BOOL allowVoiceChat;    //是否支持语音聊天
@property(nonatomic, assign, getter=isAllowEmojiChat) BOOL allowEmojiChat;    //是否支持表情聊天

@property(nonatomic, strong) JXActionView *showView;
@property(nonatomic, strong) UIButton *coverBtn;

- (instancetype)initWithChatter:(NSString *)chatter andChatType:(JXChatType)chatType;

- (instancetype)initWithConversation:(JXConversation *)conversation;

- (NSIndexPath *)indexPathForMessage:(JXMessage *)message;

- (void)addMessage:(JXMessage *)message;

- (void)removeMessage:(JXMessage *)message;

/**
 *  插入最近历史消息
 *
 *  @param loading 消息数组
 *  @param refresh 是否覆盖原有数据
 */
- (void)insertHistoryMessages:(NSArray *)loading refresh:(BOOL)refresh;

- (void)loadMessagesBefore:(JXMessage *)message;

- (BOOL)isMessageInConversation:(JXMessage *)message;

@end
