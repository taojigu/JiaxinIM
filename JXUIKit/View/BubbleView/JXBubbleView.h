//
//  JXBubbleView.h
//

#import "JXSDKHelper.h"
#import <UIKit/UIKit.h>

extern CGFloat const JXMessageCellPadding;

extern NSString *const JXMessageCellIdentifierSendText;
extern NSString *const JXMessageCellIdentifierSendLocation;
extern NSString *const JXMessageCellIdentifierSendVoice;
extern NSString *const JXMessageCellIdentifierSendVideo;
extern NSString *const JXMessageCellIdentifierSendImage;
extern NSString *const JXMessageCellIdentifierSendFile;
extern NSString *const JXMessageCellIdentifierSendAudioCall;
extern NSString *const JXMessageCellIdentifierSendVideoCall;

extern NSString *const JXMessageCellIdentifierRecvText;
extern NSString *const JXMessageCellIdentifierRecvLocation;
extern NSString *const JXMessageCellIdentifierRecvVoice;
extern NSString *const JXMessageCellIdentifierRecvVideo;
extern NSString *const JXMessageCellIdentifierRecvImage;
extern NSString *const JXMessageCellIdentifierRecvFile;
extern NSString *const JXMessageCellIdentifierRecvAudioCall;
extern NSString *const JXMessageCellIdentifierRecvVideoCall;

typedef void (^JXRichCellImageTapBlock)(void);
typedef void (^JXRichCellLinkBtnTapBlock)(void);

@interface JXBubbleView : UIView {
    UIEdgeInsets _margin;
}

@property(nonatomic) BOOL isSender;

@property(nonatomic, readonly) UIEdgeInsets margin;

@property(nonatomic) NSMutableArray *marginConstraints;

@property(nonatomic) UIImageView *backgroundImageView;

@property(nonatomic) UILabel *textLabel;

@property(nonatomic) UIImageView *imageView;
@property(nonatomic, strong) UILabel *progressLabel;

@property(nonatomic) UIImageView *locationImageView;
@property(nonatomic) UILabel *locationLabel;

@property(nonatomic) UIImageView *voiceImageView;
@property(nonatomic) UILabel *voiceDurationLabel;
@property(nonatomic) UIImageView *unReadView;

@property(nonatomic, copy) NSString *content;
@property(nonatomic, strong) NSArray *senderAnimationImages;
@property(nonatomic, strong) NSArray *recevierAnimationImages;

// RichTextMessageBubble
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *goodImageView;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) UIButton *linkBtn;
@property(nonatomic, copy) JXRichCellImageTapBlock richCellImageTapBlock;
@property(nonatomic, copy) JXRichCellLinkBtnTapBlock richCellLinkBtnTapBlock;

// FileMessageBubble
@property(nonatomic, strong) UILabel *fileNameLabel;
@property(nonatomic, strong) UILabel *fileSizeLabel;
@property(nonatomic, strong) UIImageView *fileIconView;
@property(nonatomic, strong) UIProgressView *fileProgressView;
@property(nonatomic, strong) UILabel *precentLabel;
@property(nonatomic, copy) void (^fileIconViewTapBlock)(void);

// VideoMeesageBubble
@property(nonatomic, strong) UIImageView *videoLogoView;
@property(nonatomic, strong) UILabel *videoSizeLabel;
@property(nonatomic, strong) UILabel *durationLabel;

- (instancetype)initWithMargin:(UIEdgeInsets)margin isSender:(BOOL)isSender;

@end
