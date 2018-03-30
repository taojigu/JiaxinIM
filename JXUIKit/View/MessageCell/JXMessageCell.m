//
//  JXMessageCell.m
//

#import "JXMessageCell.h"
#import "JXMessageTimeCell.h"

#import "JXBubbleView+File.h"
#import "JXBubbleView+Image.h"
#import "JXBubbleView+Location.h"
#import "JXBubbleView+RichText.h"
#import "JXBubbleView+Text.h"
#import "JXBubbleView+Voice.h"
#import "JXBubbleView+Video.h"
#import "JXEmotion.h"
#import "JXMessageFileDownloader.h"

#define UnSuportMessageTypeText @"unsupported message"

CGFloat const JXMessageTipsCellPadding = 5;
CGFloat const JXMessageCellPadding = 10;

NSString *const JXMessageCellIdentifierRecvText = @"JXMessageCellRecvText";
NSString *const JXMessageCellIdentifierRecvLocation = @"JXMessageCellRecvLocation";
NSString *const JXMessageCellIdentifierRecvVoice = @"JXMessageCellRecvVoice";
NSString *const JXMessageCellIdentifierRecvVideo = @"JXMessageCellRecvVideo";
NSString *const JXMessageCellIdentifierRecvImage = @"JXMessageCellRecvImage";
NSString *const JXMessageCellIdentifierRecvFile = @"JXMessageCellRecvFile";
NSString *const JXMessageCellIdentifierRecvAudioCall = @"JXMessageCellRecvAudioCall";
NSString *const JXMessageCellIdentifierRecvVideoCall = @"JXMessageCellRecvVideoCall";
NSString *const JXMessageCellIdentifierRecvRichText = @"JXMessageCellRecvRichText";

NSString *const JXMessageCellIdentifierSendText = @"JXMessageCellSendText";
NSString *const JXMessageCellIdentifierSendLocation = @"JXMessageCellSendLocation";
NSString *const JXMessageCellIdentifierSendVoice = @"JXMessageCellSendVoice";
NSString *const JXMessageCellIdentifierSendVideo = @"JXMessageCellSendVideo";
NSString *const JXMessageCellIdentifierSendImage = @"JXMessageCellSendImage";
NSString *const JXMessageCellIdentifierSendFile = @"JXMessageCellSendFile";
NSString *const JXMessageCellIdentifierSendAudioCall = @"JXMessageCellSendAudioCall";
NSString *const JXMessageCellIdentifierSendVideoCall = @"JXMessageCellSendVideoCall";
NSString *const JXMessageCellIdentifierSendRichText = @"JXMessageCellSendRichText";

@interface JXMessageCell ()

@property(nonatomic) NSLayoutConstraint *statusWidthConstraint;
@property(nonatomic) NSLayoutConstraint *activtiyWidthConstraint;
@property(nonatomic) NSLayoutConstraint *hasReadWidthConstraint;
@property(nonatomic) NSLayoutConstraint *bubbleMaxWidthConstraint;

@property(nonatomic, strong) UIColor *senderBackFillColor;
@property(nonatomic, strong) UIColor *recieveBackFillColor;

@end

@implementation JXMessageCell

+ (void)initialize {
    // UIAppearance Proxy Defaults
    JXMessageCell *cell = [self appearance];
    cell.statusSize = 20;
    cell.activitySize = 20;
    cell.bubbleMaxWidth = 210;
    cell.leftBubbleMargin = UIEdgeInsetsMake(8, 15, 8, 10);
    cell.rightBubbleMargin = UIEdgeInsetsMake(8, 10, 8, 15);
    cell.bubbleMargin = UIEdgeInsetsMake(8, 0, 8, 0);

    cell.messageTextFont = [UIFont systemFontOfSize:15];
    cell.messageTextColor = [UIColor blackColor];

    cell.messageLocationFont = [UIFont systemFontOfSize:12];
    cell.messageLocationColor = [UIColor whiteColor];

    cell.messageVoiceDurationColor = [UIColor grayColor];
    cell.messageVoiceDurationFont = [UIFont systemFontOfSize:12];

    cell.messageFileNameColor = [UIColor blackColor];
    cell.messageFileNameFont = [UIFont systemFontOfSize:13];
    cell.messageFileSizeColor = [UIColor grayColor];
    cell.messageFileSizeFont = [UIFont systemFontOfSize:11];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                      message:(JXMessage *)message {
    JXMessageCell *cell = [JXMessageCell appearance];
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _statusSize = cell.statusSize;
        _activitySize = cell.activitySize;
        _bubbleMaxWidth = cell.bubbleMaxWidth;
        _leftBubbleMargin = cell.leftBubbleMargin;
        _rightBubbleMargin = cell.rightBubbleMargin;
        _bubbleMargin = cell.bubbleMargin;
        _messageTextFont = cell.messageTextFont;
        _messageTextColor = cell.messageTextColor;
        _messageLocationFont = cell.messageLocationFont;
        _messageLocationColor = cell.messageLocationColor;
        _messageVoiceDurationColor = cell.messageVoiceDurationColor;
        _messageVoiceDurationFont = cell.messageVoiceDurationFont;
        _messageFileNameColor = cell.messageFileNameColor;
        _messageFileNameFont = cell.messageFileNameFont;
        _messageFileSizeColor = cell.messageFileSizeColor;
        _messageFileSizeFont = cell.messageFileSizeFont;

        if (message.type == JXMessageTypeTips) {
            [self _setupTipSubviewWithMessage:message];
        } else {
            [self _setupSubviewsWithMessage:message];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isSelected) {
        // 删除掉选择状态的背景避免出现蓝色
        [self.selectedBackgroundView removeFromSuperview];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - setup subviews

- (void)_setupTipSubviewWithMessage:(JXMessage *)message {
    JXMessageTimeCell *timeCell = [JXMessageTimeCell appearance];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = timeCell.titleLabelColor;
    _titleLabel.font = timeCell.titleLabelFont;
    _titleLabel.text = [NSString stringWithFormat:@" %@ ", message.textToDisplay];
    _titleLabel.backgroundColor = timeCell.titleLabelBkgColor;
    _titleLabel.layer.cornerRadius = timeCell.titleLabelCornerRadious;
    _titleLabel.clipsToBounds = YES;
    [self.contentView addSubview:_titleLabel];

    [self _setupTitleLabelConstraints];
}

- (void)_setupTitleLabelConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:JXMessageTipsCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-JXMessageTipsCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
}

- (void)_setupSubviewsWithMessage:(JXMessage *)message {
    self.senderBackFillColor = JXColorWithRGB(196.0, 231.0, 251.0);
    self.recieveBackFillColor = JXPureColor(252.0);
    _statusButton = [[UIButton alloc] init];
    _statusButton.translatesAutoresizingMaskIntoConstraints = NO;
    _statusButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_statusButton setImage:JXChatImage(@"ms_failed") forState:UIControlStateNormal];
    [_statusButton addTarget:self
                      action:@selector(statusAction)
            forControlEvents:UIControlEventTouchUpInside];
    [_statusButton sizeToFit];
    _statusButton.hidden = YES;
    [self.contentView addSubview:_statusButton];

    _bubbleView = [[JXBubbleView alloc]
            initWithMargin:(message.isSender ? _rightBubbleMargin : _leftBubbleMargin)
                  isSender:message.isSender];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    _bubbleView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_bubbleView];

    _avatarView = [[UIImageView alloc] init];
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.clipsToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatarView];

    _hasRead = [[UILabel alloc] init];
    _hasRead.translatesAutoresizingMaskIntoConstraints = NO;
    _hasRead.text = @"sent";
    _hasRead.textAlignment = NSTextAlignmentRight;
    _hasRead.font = [UIFont systemFontOfSize:12];
    _hasRead.textColor = [UIColor grayColor];
    _hasRead.hidden = YES;
    [_hasRead sizeToFit];
    [self.contentView addSubview:_hasRead];

    _activity = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activity.translatesAutoresizingMaskIntoConstraints = NO;
    _activity.backgroundColor = [UIColor clearColor];
    _activity.color = [UIColor grayColor];
    _activity.hidesWhenStopped = YES;
    _activity.hidden = YES;
    [self.contentView addSubview:_activity];

    _foreseeStatusView = [[UIImageView alloc] initWithImage:JXChatImage(@"pencil_icon")];
    _foreseeStatusView.translatesAutoresizingMaskIntoConstraints = NO;
    _foreseeStatusView.hidden = YES;
    [self.contentView addSubview:_foreseeStatusView];

    if ([self isCustomBubbleView:message]) {
        [self setupCustomBubbleView:message];
    } else {
        switch (message.type) {
            case JXMessageTypeForeseeComposing:
            case JXMessageTypeForeseeRecording:
            case JXMessageTypeVoiceCall:
            case JXMessageTypeVideoCall:
            case JXMessageTypeText: {
                [_bubbleView setupTextBubbleView];
                _bubbleView.textLabel.font = _messageTextFont;
                _bubbleView.textLabel.textColor = _messageTextColor;
            } break;
            case JXMessageTypeImage: {
                [_bubbleView setupImageBubbleView];
                _bubbleView.imageView.image = message.defaultImage;
            } break;
            case JXMessageTypeLocation: {
                [_bubbleView setupLocationBubbleView];
                _bubbleView.locationImageView.image =
                        [JXChatImage(@"chat_location_preview") stretchableImageWithLeftCapWidth:10
                                                                                   topCapHeight:10];
                _bubbleView.locationLabel.font = _messageLocationFont;
                _bubbleView.locationLabel.textColor = _messageLocationColor;
            } break;
            case JXMessageTypeAudio: {
                [_bubbleView setupVoiceBubbleView];
                _bubbleView.voiceDurationLabel.textColor = _messageVoiceDurationColor;
                _bubbleView.voiceDurationLabel.font = _messageVoiceDurationFont;
            } break;
            case JXMessageTypeRichText: {
                WEAKSELF;
                [_bubbleView setupRichBubbleView];
                _bubbleView.goodImageView.image = message.defaultImage;
                _bubbleView.richCellImageTapBlock = ^{
                    if (weakSelf.delegate &&
                        [weakSelf.delegate
                                respondsToSelector:@selector(richMessageCellSelected:isImage:)]) {
                        [weakSelf.delegate richMessageCellSelected:message isImage:YES];
                    }
                };
                _bubbleView.richCellLinkBtnTapBlock = ^{
                    if (weakSelf.delegate &&
                        [weakSelf.delegate
                                respondsToSelector:@selector(richMessageCellSelected:isImage:)]) {
                        [weakSelf.delegate richMessageCellSelected:message isImage:NO];
                    }
                };
            } break;
            case JXMessageTypeFile: {
                [_bubbleView setupFileBubbleView];
            } break;
            case JXMessageTypeVideo: {
                [_bubbleView setupVideoBubbleView];
                _bubbleView.imageView.image = message.defaultImage;
            } break;
            default:
                break;
        }
    }

    [self _setupConstraints];

    UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(bubbleViewTapAction:)];
    [_bubbleView addGestureRecognizer:tapRecognizer];

    UITapGestureRecognizer *tapRecognizer2 =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(avatarViewTapAction:)];
    [_avatarView addGestureRecognizer:tapRecognizer2];
}

#pragma mark - Setup Constraints

- (void)_setupConstraints {
    // bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-JXMessageCellPadding]];

    self.bubbleMaxWidthConstraint =
            [NSLayoutConstraint constraintWithItem:self.bubbleView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:self.bubbleMaxWidth];
    [self addConstraint:self.bubbleMaxWidthConstraint];
    //    self.bubbleMaxWidthConstraint.active = YES;

    // status button
    if (self.statusSize) {
        self.statusWidthConstraint =
                [NSLayoutConstraint constraintWithItem:self.statusButton
                                             attribute:NSLayoutAttributeWidth
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeNotAnAttribute
                                            multiplier:1.0
                                              constant:self.statusSize];
        [self addConstraint:self.statusWidthConstraint];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.statusButton
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0]];
    }

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.bubbleView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    // activtiy
    self.activtiyWidthConstraint =
            [NSLayoutConstraint constraintWithItem:self.activity
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:self.activitySize];
    [self addConstraint:self.activtiyWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.activity
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    [self _updateHasReadWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.statusButton
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];
    // foreseeStatusView
    if (_foreseeStatusView) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.foreseeStatusView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.foreseeStatusView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.bubbleView
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1
                                                          constant:8]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.foreseeStatusView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.foreseeStatusView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.foreseeStatusView
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0]];
    }
}

#pragma mark - Update Constraint

- (void)_updateHasReadWidthConstraint {
    if (!_hasRead) return;
    [self removeConstraint:self.hasReadWidthConstraint];

    self.hasReadWidthConstraint =
            [NSLayoutConstraint constraintWithItem:_hasRead
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:0
                                          constant:40];
    [self addConstraint:self.hasReadWidthConstraint];
}

- (void)_updateStatusButtonWidthConstraint {
    if (!_statusButton) return;
    [self removeConstraint:self.statusWidthConstraint];

    self.statusWidthConstraint =
            [NSLayoutConstraint constraintWithItem:self.statusButton
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:0
                                          constant:self.statusSize];
    [self addConstraint:self.statusWidthConstraint];
}

- (void)_updateActivityWidthConstraint {
    if (!_activity) return;
    [self removeConstraint:self.activtiyWidthConstraint];

    self.statusWidthConstraint =
            [NSLayoutConstraint constraintWithItem:self.activity
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:0
                                          constant:self.activitySize];
    [self addConstraint:self.activtiyWidthConstraint];
}

- (void)_updateBubbleMaxWidthConstraint {
    if (!_bubbleView) return;
    [self removeConstraint:self.bubbleMaxWidthConstraint];

    self.bubbleMaxWidthConstraint =
            [NSLayoutConstraint constraintWithItem:self.bubbleView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:self.bubbleMaxWidth];
    [self addConstraint:self.bubbleMaxWidthConstraint];
}

#pragma mark - setter

- (void)setMessage:(JXMessage *)message {
    _message = message;
    if ([self isCustomBubbleView:message]) {
        [self setCustomMessage:message];
    } else {
        switch (message.type) {
            case JXMessageTypeForeseeComposing:
            case JXMessageTypeText: {
                if (message.attributedText) {
                    [message.attributedText
                            addAttribute:NSFontAttributeName
                                   value:self.messageTextFont
                                   range:NSMakeRange(0, [message.attributedText.string length])];
                    [_bubbleView.textLabel setAttributedText:message.attributedText];
                } else {
                    _bubbleView.textLabel.text = message.textWithEmoji;
                    _bubbleView.textLabel.font = self.messageTextFont;
                }
                if (message.type == JXMessageTypeForeseeComposing) {
                    _foreseeStatusView.hidden = NO;
                } else {
                    _foreseeStatusView.hidden = YES;
                }
            } break;
            case JXMessageTypeImage: {
                UIImage *image = [UIImage
                        imageWithContentsOfFile:_message.isSender ? _message.localURL
                                                                  : _message.thumbUrlToDisplay];
                if (image) _bubbleView.imageView.image = image;
            } break;
            case JXMessageTypeLocation: {
                _bubbleView.locationLabel.text = _message.label;
                _bubbleView.locationImageView.image = JXChatImage(@"LocationDefault");
            } break;
            case JXMessageTypeAudio: {
                if (_bubbleView.voiceImageView) {
                    self.bubbleView.voiceImageView.image =
                            self.message.isSender ? JXChatImage(@"voiceMes_Send")
                                                  : JXChatImage(@"voiceMes_Recieved");
                    _bubbleView.voiceImageView.animationImages =
                            _message.isSender ? self.sendMessageVoiceAnimationImages
                                              : self.recvMessageVoiceAnimationImages;
                }
                if (!_message.isSender) {
                    _bubbleView.unReadView.hidden = _message.isRead;
                }

                if (_message.isMediaPlaying) {
                    [_bubbleView.voiceImageView startAnimating];
                } else {
                    [_bubbleView.voiceImageView stopAnimating];
                }

                _bubbleView.voiceDurationLabel.text = _message.durationDes;
            } break;
            case JXMessageTypeVoiceCall: {
                UIImage *image = message.isSender ? JXChatImage(@"MessageCallAudio")
                                                  : JXChatImage(@"MessageCallAudioRecieve");
                _bubbleView.textLabel.attributedText =
                        [self attributedStringWithText:message.textToDisplay image:image];

            } break;
            case JXMessageTypeVideoCall: {
                UIImage *image = message.isSender ? JXChatImage(@"MessageCallVideo")
                                                  : JXChatImage(@"MessageCallVideoRecieve");
                _bubbleView.textLabel.attributedText =
                        [self attributedStringWithText:message.textToDisplay image:image];
            } break;
            case JXMessageTypeRichText: {
                _bubbleView.titleLabel.text = message.title;
                _bubbleView.priceLabel.text = message.content;
                UIImage *image = [UIImage
                                  imageWithContentsOfFile:_message.isSender ? _message.localURL
                                  : _message.thumbUrlToDisplay];
//                UIImage *thumb = [UIImage imageWithContentsOfFile:message.thumbUrlToDisplay];
                if (image) _bubbleView.goodImageView.image = image;
            } break;
            case JXMessageTypeFile: {
                NSData *data = [NSData dataWithContentsOfFile:message.localURL];
                if ([data length] < [message fileSize]) {
                    self.bubbleView.fileIconView.image = JXChatImage(@"file_icon");
                } else {
                    self.bubbleView.fileIconView.image = JXChatImage(@"file_icon_finish");
                }
                self.bubbleView.fileNameLabel.text = message.fileName;
                self.bubbleView.fileSizeLabel.text = message.fileSizeDes;
                WEAKSELF;
                self.bubbleView.fileIconViewTapBlock = ^() {
                    if ([weakSelf.delegate
                                respondsToSelector:@selector(messageCell:
                                                           fileMessageIconViewSelected:)]) {
                        [weakSelf.delegate messageCell:weakSelf
                                fileMessageIconViewSelected:message];
                    }
                };
            } break;
            case JXMessageTypeVideo: {
                UIImage *image = [UIImage imageWithContentsOfFile: _message.thumbUrlToDisplay];
                if (!image) {
                    image = [UIImage imageWithColor:[UIColor grayColor]];
                }
                if (image) _bubbleView.imageView.image = image;
                _bubbleView.videoSizeLabel.text = message.fileSizeDes;
                _bubbleView.durationLabel.text = message.durationDes;
                // FIXME: 微信视频时长存在问题，暂时都不显示
                _bubbleView.durationLabel.hidden = YES;
                //  if (message.duration == 0) {
                //    _bubbleView.durationLabel.hidden = YES;
                //  } else {
                //    _bubbleView.durationLabel.hidden = NO;
                //  }
            } break;
            case JXMessageTypeTips: {
                self.titleLabel.text = [NSString stringWithFormat:@" %@ ", message.textToDisplay];
            } break;
            case JXMessageTypePicText: {
                // FIXME: 2.3.5图文消息类型
            }
            default: {
                _bubbleView.textLabel.text = UnSuportMessageTypeText;
            } break;
        }
    }
}

- (void)switchVoicePlayingAnimation {
    if ([self.bubbleView.voiceImageView isAnimating]) {
        [self.bubbleView stopPlayAnimation];
    } else {
        [self.bubbleView startPlayVoiceAnimation];
    }
}

- (NSAttributedString *)attributedStringWithText:(NSString *)str image:(UIImage *)image {
    //新建文字附件来存放我们的图片
    NSString *text = [NSString stringWithFormat:@"a %@", str];
    NSMutableAttributedString *attributedString =
            [[NSMutableAttributedString alloc] initWithString:text];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    //                    CGFloat n = 25/12;
    textAttachment.bounds =
            CGRectMake(textAttachment.bounds.origin.x, textAttachment.bounds.origin.y - 3, 16, 16);

    //给附件添加图片
    textAttachment.image = image;

    //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
    NSAttributedString *imageStr =
            [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:imageStr];
    return attributedString;
}

- (void)setStatusSize:(CGFloat)statusSize {
    _statusSize = statusSize;
    if (self.message.type != JXMessageTypeTips) {
        [self _updateStatusButtonWidthConstraint];
    }
}

- (void)setActivitySize:(CGFloat)activitySize {
    _activitySize = activitySize;
    if (self.message.type != JXMessageTypeTips) {
        [self _updateActivityWidthConstraint];
    }
}

- (void)setSendBubbleBackgroundImage:(UIImage *)sendBubbleBackgroundImage {
    _sendBubbleBackgroundImage = sendBubbleBackgroundImage;
}

- (void)setRecvBubbleBackgroundImage:(UIImage *)recvBubbleBackgroundImage {
    _recvBubbleBackgroundImage = recvBubbleBackgroundImage;
}

- (void)setBubbleMaxWidth:(CGFloat)bubbleMaxWidth {
    _bubbleMaxWidth = bubbleMaxWidth;
    if ([self isCustomBubbleView:_message]) {
        return;
    }
    [self _updateBubbleMaxWidthConstraint];
}

- (void)setRightBubbleMargin:(UIEdgeInsets)rightBubbleMargin {
    _rightBubbleMargin = rightBubbleMargin;
}

- (void)setLeftBubbleMargin:(UIEdgeInsets)leftBubbleMargin {
    _leftBubbleMargin = leftBubbleMargin;
}

- (void)setBubbleMargin:(UIEdgeInsets)bubbleMargin {
    _bubbleMargin = bubbleMargin;
    _bubbleMargin = _message.isSender ? _rightBubbleMargin : _leftBubbleMargin;
    if ([self isCustomBubbleView:_message]) {
        [self updateCustomBubbleViewMargin:_bubbleMargin message:_message];
    } else {
        if (_bubbleView) {
            switch (_message.type) {
                case JXMessageTypeText: {
                    [_bubbleView updateTextMargin:_bubbleMargin];
                } break;
                case JXMessageTypeImage: {
                    [_bubbleView updateImageMargin:_bubbleMargin];
                } break;
                case JXMessageTypeLocation: {
                    [_bubbleView updateLocationMargin:_bubbleMargin];
                } break;
                case JXMessageTypeAudio: {
                    [_bubbleView updateVoiceMargin:_bubbleMargin];
                } break;
                case JXMessageTypeVoiceCall:
                case JXMessageTypeVideoCall: {
                    [_bubbleView updateTextMargin:_bubbleMargin];
                } break;
                case JXMessageTypeRichText: {
                    [_bubbleView updateRichMargin:_bubbleMargin];
                } break;
                case JXMessageTypeFile: {
                    [_bubbleView updateFileMargin:_bubbleMargin];
                } break;
                case JXMessageTypeVideo: {
                    [_bubbleView updateVideoMargin:_bubbleMargin];
                }
                default:
                    break;
            }
        }
    }
}

- (void)setMessageTextFont:(UIFont *)messageTextFont {
    _messageTextFont = messageTextFont;
    if (_bubbleView.textLabel) {
        _bubbleView.textLabel.font = messageTextFont;
    }
}

- (void)setMessageTextColor:(UIColor *)messageTextColor {
    _messageTextColor = messageTextColor;
    if (_bubbleView.textLabel) {
        _bubbleView.textLabel.textColor = _messageTextColor;
    }
}

- (void)setMessageLocationColor:(UIColor *)messageLocationColor {
    _messageLocationColor = messageLocationColor;
    if (_bubbleView.locationLabel) {
        _bubbleView.locationLabel.textColor = _messageLocationColor;
    }
}

- (void)setMessageLocationFont:(UIFont *)messageLocationFont {
    _messageLocationFont = messageLocationFont;
    if (_bubbleView.locationLabel) {
        _bubbleView.locationLabel.font = _messageLocationFont;
    }
}

- (void)setSendMessageVoiceAnimationImages:(NSArray *)sendMessageVoiceAnimationImages {
    _sendMessageVoiceAnimationImages = sendMessageVoiceAnimationImages;
}

- (void)setRecvMessageVoiceAnimationImages:(NSArray *)recvMessageVoiceAnimationImages {
    _recvMessageVoiceAnimationImages = recvMessageVoiceAnimationImages;
}

- (void)setMessageVoiceDurationColor:(UIColor *)messageVoiceDurationColor {
    _messageVoiceDurationColor = messageVoiceDurationColor;
    if (_bubbleView.voiceDurationLabel) {
        _bubbleView.voiceDurationLabel.textColor = _messageVoiceDurationColor;
    }
}

- (void)setMessageVoiceDurationFont:(UIFont *)messageVoiceDurationFont {
    _messageVoiceDurationFont = messageVoiceDurationFont;
    if (_bubbleView.voiceDurationLabel) {
        _bubbleView.voiceDurationLabel.font = _messageVoiceDurationFont;
    }
}

- (void)setMessageFileNameFont:(UIFont *)messageFileNameFont {
    _messageFileNameFont = messageFileNameFont;
    if (_bubbleView.fileNameLabel) {
        _bubbleView.fileNameLabel.font = messageFileNameFont;
    }
}

- (void)setMessageFileSizeFont:(UIFont *)messageFileSizeFont {
    _messageFileSizeFont = messageFileSizeFont;
    if (_bubbleView.fileSizeLabel) {
        _bubbleView.fileSizeLabel.font = messageFileSizeFont;
    }
}

- (void)setMessageFileNameColor:(UIColor *)messageFileNameColor {
    _messageFileNameColor = messageFileNameColor;
    if (_bubbleView.fileNameLabel) {
        _bubbleView.fileNameLabel.textColor = messageFileNameColor;
    }
}

- (void)setMessageFileSizeColor:(UIColor *)messageFileSizeColor {
    _messageFileSizeColor = messageFileSizeColor;
    if (_bubbleView.fileSizeLabel) {
        _bubbleView.fileSizeLabel.textColor = messageFileSizeColor;
    }
}

- (void)updateMessageStatus {
    if (self.message.progress > 0) {
        if (self.message.type == JXMessageTypeFile) {
            [self.bubbleView.fileProgressView setProgress:self.message.progress animated:NO];
            self.bubbleView.precentLabel.text =
                    [NSString stringWithFormat:@"%.1f%%", self.message.progress * 100];
            self.bubbleView.fileIconView.hidden = YES;
            self.bubbleView.fileProgressView.hidden = NO;
            self.bubbleView.precentLabel.hidden = NO;
            if (self.message.progress >= 1) {
                self.bubbleView.fileProgressView.hidden = YES;
                self.bubbleView.precentLabel.hidden = YES;
                self.bubbleView.fileIconView.hidden = NO;
                self.bubbleView.fileIconView.image = JXChatImage(@"file_icon_finish");
            }
        } else {
            [self.bubbleView.progressLabel setBackgroundColor:JXPureAlphaColor(211, 0.6)];
            self.bubbleView.progressLabel.text =
                    [NSString stringWithFormat:@"%.1f%%", self.message.progress * 100];
            if (self.message.progress >= 1) {
                [self.bubbleView.progressLabel setBackgroundColor:[UIColor clearColor]];
                self.bubbleView.progressLabel.text = @"";
            }
        }
    } else if (self.message.progress < 0) {    // 小于0说明下载失败
        if (self.message.type == JXMessageTypeFile) {
            self.bubbleView.precentLabel.hidden = YES;
            self.bubbleView.fileProgressView.hidden = YES;
            self.bubbleView.fileIconView.hidden = NO;
            self.bubbleView.fileIconView.image = JXChatImage(@"file_icon_finish");
        }
    }
}

#pragma mark - action

- (void)bubbleViewTapAction:(UITapGestureRecognizer *)tapRecognizer {
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.message.type == JXMessageTypeAudio) {
            [self.bubbleView startPlayVoiceAnimation];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(messageCellSelected:)]) {
            [_delegate messageCellSelected:_message];
        }
    }
}

- (void)avatarViewTapAction:(UITapGestureRecognizer *)tapRecognizer {
    if ([_delegate respondsToSelector:@selector(avatarViewSelcted:)]) {
        [_delegate avatarViewSelcted:_message];
    }
}

- (void)statusAction {
    if ([_delegate respondsToSelector:@selector(statusButtonSelcted:)]) {
        [_delegate statusButtonSelcted:_message];
    }
}

#pragma mark - customize

- (BOOL)isCustomBubbleView:(JXMessage *)message {
    return NO;
}

- (void)setCustomMessage:(JXMessage *)message {
}

- (void)setupCustomBubbleView:(JXMessage *)message {
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin message:(JXMessage *)message {
}

#pragma mark - public

#define CELL_ID_FOR_MESSAGE(m, t) \
    (m.isSender ? JXMessageCellIdentifierSend##t : JXMessageCellIdentifierRecv##t)
#define CELL_ID_FOR_TIPMESSAGE @"JXMessageCellIdentifierTips"
#define CELL_ID_FOR_REQUESTMESSAGE @"JXMessageCellIdentifierRequest"

+ (NSString *)cellIdentifierForMessage:(JXMessage *)message {
    NSString *cellIdentifier = nil;
    switch (message.type) {
        case JXMessageTypeText:
        case JXMessageTypeVoiceCall:
        case JXMessageTypeVideoCall:
        case JXMessageTypeForeseeComposing:
            cellIdentifier = CELL_ID_FOR_MESSAGE(message, Text);
            break;
        case JXMessageTypeImage:
            cellIdentifier = CELL_ID_FOR_MESSAGE(message, Image);
            break;
        case JXMessageTypeVideo:
            cellIdentifier = CELL_ID_FOR_MESSAGE(message, Video);
            break;
        case JXMessageTypeLocation:
            cellIdentifier = CELL_ID_FOR_MESSAGE(message, Location);
            break;
        case JXMessageTypeAudio:
            cellIdentifier = CELL_ID_FOR_MESSAGE(message, Voice);
            break;
        case JXMessageTypeFile:
            cellIdentifier = CELL_ID_FOR_MESSAGE(message, File);
            break;
        case JXMessageTypeRichText:
            cellIdentifier = CELL_ID_FOR_MESSAGE(message, RichText);
            break;
        case JXMessageTypeTips:
            cellIdentifier = CELL_ID_FOR_TIPMESSAGE;
            break;
        default:
            break;
    }
    return cellIdentifier;
}

+ (CGFloat)cellHeightForMessage:(JXMessage *)message {
    if (message.type == JXMessageTypeTips) return 0;
    if (message.cellHeight > 0) {
        return message.cellHeight;
    }

    JXMessageCell *cell = [self appearance];
    CGFloat bubbleMaxWidth = cell.bubbleMaxWidth;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        bubbleMaxWidth = 200;
    }
    bubbleMaxWidth -= (cell.leftBubbleMargin.left + cell.leftBubbleMargin.right +
                       cell.rightBubbleMargin.left + cell.rightBubbleMargin.right) /
                      2;

    CGFloat height = JXMessageCellPadding + cell.bubbleMargin.top + cell.bubbleMargin.bottom;

    switch (message.type) {
        case JXMessageTypeForeseeComposing:
        case JXMessageTypeEvaluation:
        case JXMessageTypeVoiceCall:
        case JXMessageTypeVideoCall:
        case JXMessageTypeText: {
            CGRect rect;
            [message setCellWidth:(cell.bubbleMaxWidth - JXMessageCellPadding * 2)];
            NSMutableAttributedString *text = message.attributedText;
            if (text) {
                [text addAttribute:NSFontAttributeName
                               value:cell.messageTextFont
                               range:NSMakeRange(0, [text.string length])];
                rect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin |
                                                  NSStringDrawingUsesFontLeading
                                          context:nil];
            } else {
                rect = [message.textWithEmoji
                        boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{
                                      NSFontAttributeName : cell.messageTextFont
                                  }
                                     context:nil];
            }
            height += (rect.size.height > 20 ? rect.size.height : 20) + 10;
        } break;
        case JXMessageTypeImage:
        case JXMessageTypeVideo: {
            CGSize retSize = message.thumbnailImageSize;
            if (retSize.width == 0 || retSize.height == 0) {
                retSize.width = kJXMessageImageSizeWidth;
                retSize.height = kJXMessageImageSizeHeight;
            } else if (retSize.width > retSize.height) {
                CGFloat height = kJXMessageImageSizeWidth / retSize.width * retSize.height;
                retSize.height = height;
                retSize.width = kJXMessageImageSizeWidth;
            } else {
                CGFloat width = kJXMessageImageSizeHeight / retSize.height * retSize.width;
                retSize.width = width;
                retSize.height = kJXMessageImageSizeHeight;
            }
            height += retSize.height;
        } break;
        case JXMessageTypeLocation: {
            height += kJXMessageLocationHeight;
        } break;
        case JXMessageTypeAudio: {
            height += kJXMessageVoiceHeight;
        } break;
        case JXMessageTypeFile: {
            NSString *text = message.fileName;
            UIFont *font = cell.messageFileNameFont;
            CGRect nameRect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{
                                                  NSFontAttributeName : font
                                              }
                                                 context:nil];
            height += (nameRect.size.height > 20 ? nameRect.size.height : 20);

            text = message.fileSizeDes;
            font = cell.messageFileSizeFont;
            CGRect sizeRect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{
                                                  NSFontAttributeName : font
                                              }
                                                 context:nil];
            height += (sizeRect.size.height > 15 ? sizeRect.size.height : 15);
        } break;
        case JXMessageTypeRichText: {
            NSString *content = message.content;
            UIFont *font = [UIFont systemFontOfSize:14.f];
            CGRect contentRect = [content boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName : font}
                                                       context:nil];
            height = 140 + contentRect.size.height ;
//            height = 300;
        } break;
        default:{
            CGRect rect = [UnSuportMessageTypeText
                                boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin |
                                                     NSStringDrawingUsesFontLeading
                                          attributes:@{
                                                    NSFontAttributeName : cell.messageTextFont
                                                     }
                                             context:nil];
            [message setCellWidth:(cell.bubbleMaxWidth - JXMessageCellPadding * 2)];
            height += (rect.size.height > 20 ? rect.size.height : 20) + 10;
        } break;
    }

    height += JXMessageCellPadding;
    message.cellHeight = height;

    return height;
}

@end
