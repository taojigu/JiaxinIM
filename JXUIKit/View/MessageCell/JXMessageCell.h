//
//  JXMessageCell.h
//

#import <UIKit/UIKit.h>

#import "JXBubbleView.h"
#import "JXMessage+Extends.h"

#define kJXMessageImageSizeWidth 120
#define kJXMessageImageSizeHeight 120
#define kJXMessageLocationHeight 95
#define kJXMessageVoiceHeight 23

extern CGFloat const JXMessageCellPadding;

typedef NS_ENUM(NSInteger, JXMessageCellTapEvent) {
    kJXMessageCellEventImageBubbleTap,
    kJXMessageCellEventLocationBubbleTap,
    kJXMessageCellEventAudioBubbleTap,
    kJXMessageCellEventVideoBubbleTap,
    kJXMessageCellEventFileBubbleTap,
    kJXMessageCellEventCustomBubbleTap,
};

typedef NS_ENUM(NSUInteger, MessageCellActiveType) {
    kMessageActiveTypeCopy,
    kMessageActiveTypeForward,
    kMessageActiveTypeCollect,
    kMessageActiveTypeMore,
    kMessageActiveTypeDelete,
    kMessageActiveTypeMutipleSelect
};

typedef NS_ENUM(NSInteger, JXMessageTextCellSelectedType) {
    kJXMessageTextCellEventPhoneTap = 1,
    kJXMessageTextCellEventUrlTap,
};

typedef void (^IMMessageCellEditActiveBlock)(MessageCellActiveType activeType);
@class JXMessageCell;

@protocol JXMessageCellDelegate<NSObject>

@optional

- (void)messageCellSelected:(JXMessage *)message;

- (void)statusButtonSelcted:(JXMessage *)message;

- (void)avatarViewSelcted:(JXMessage *)message;

- (void)messageCellLongPress:(JXMessage *)message;

- (void)richMessageCellSelected:(JXMessage *)message isImage:(BOOL)isImage;

- (void)messageCell:(JXMessageCell *)cell fileMessageIconViewSelected:(JXMessage *)message;

@end

@interface JXMessageCell : UITableViewCell

@property(nonatomic, weak) id<JXMessageCellDelegate> delegate;

@property(nonatomic) UIActivityIndicatorView *activity;

@property(nonatomic) UIImageView *avatarView;

@property(nonatomic) UILabel *nameLabel;

@property(nonatomic) UILabel *titleLabel;

@property(nonatomic) UIButton *statusButton;

@property(nonatomic) UILabel *hasRead;

@property(nonatomic) JXBubbleView *bubbleView;

@property (nonatomic, strong) UIImageView *foreseeStatusView;

@property(nonatomic) JXMessage *message;

@property(nonatomic) CGFloat statusSize UI_APPEARANCE_SELECTOR;

@property(nonatomic) CGFloat activitySize UI_APPEARANCE_SELECTOR;

@property(nonatomic) CGFloat bubbleMaxWidth UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIEdgeInsets bubbleMargin UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIEdgeInsets leftBubbleMargin UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIEdgeInsets rightBubbleMargin UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIImage *sendBubbleBackgroundImage UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIImage *recvBubbleBackgroundImage UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIFont *messageTextFont UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIColor *messageTextColor UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIFont *messageLocationFont UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIColor *messageLocationColor UI_APPEARANCE_SELECTOR;

@property(nonatomic) NSArray *sendMessageVoiceAnimationImages UI_APPEARANCE_SELECTOR;

@property(nonatomic) NSArray *recvMessageVoiceAnimationImages UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIColor *messageVoiceDurationColor UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIFont *messageVoiceDurationFont UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIFont *messageFileNameFont UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIColor *messageFileNameColor UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIFont *messageFileSizeFont UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIColor *messageFileSizeColor UI_APPEARANCE_SELECTOR;

- (void)updateMessageStatus;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                      message:(JXMessage *)message;

+ (NSString *)cellIdentifierForMessage:(JXMessage *)message;

+ (CGFloat)cellHeightForMessage:(JXMessage *)message;


#pragma mark - customize

- (BOOL)isCustomBubbleView:(JXMessage *)message;

- (void)setCustomMessage:(JXMessage *)message;

- (void)setupCustomBubbleView:(JXMessage *)message;

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin message:(JXMessage *)message;

@end
