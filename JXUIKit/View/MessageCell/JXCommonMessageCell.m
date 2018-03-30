//
//  JXCommonMessageCell.m
//

#import "JXCommonMessageCell.h"

@interface JXCommonMessageCell ()

@property(nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property(nonatomic) NSLayoutConstraint *nameHeightConstraint;

@property(nonatomic) NSLayoutConstraint *bubbleWithAvatarRightConstraint;
@property(nonatomic) NSLayoutConstraint *bubbleWithoutAvatarRightConstraint;

@property(nonatomic) NSLayoutConstraint *bubbleWithNameTopConstraint;
@property(nonatomic) NSLayoutConstraint *bubbleWithoutNameTopConstraint;
@property(nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;

@end

@implementation JXCommonMessageCell

+ (void)initialize {
    [super initialize];
    // UIAppearance Proxy Defaults
    JXCommonMessageCell *cell = [self appearance];
    cell.avatarSize = 45;
    cell.avatarCornerRadius = cell.avatarSize / 2.0;

    cell.messageNameColor = [UIColor grayColor];
    cell.messageNameFont = [UIFont systemFontOfSize:10];
    cell.messageNameHeight = 15;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        cell.messageNameIsHidden = NO;
    }
    //cell.bubbleMargin = UIEdgeInsetsMake(8, 15, 8, 10);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                      message:(JXMessage *)message {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier message:message]) {
        JXCommonMessageCell *cell = [JXCommonMessageCell appearance];
        _avatarSize = cell.avatarSize;
        _avatarCornerRadius = cell.avatarCornerRadius;
        _messageNameColor = cell.messageNameColor;
        _messageNameFont = cell.messageNameFont;
        _messageNameHeight = cell.messageNameHeight;

        self.backgroundColor = [UIColor clearColor];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = _messageNameFont;
        self.nameLabel.textColor = _messageNameColor;
        [self.contentView addSubview:self.nameLabel];

        [self configureLayoutConstraintsWithModel:message];
        if (message.isSender) {
            self.messageTextColor = [UIColor whiteColor];
        } else {
            self.messageTextColor = JXColorWithRGB(50, 50, 50);
        }

        if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
            self.messageNameHeight = 15;
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bubbleView.backgroundImageView.image =
            self.message.isSender ? self.sendBubbleBackgroundImage : self.recvBubbleBackgroundImage;

    switch (self.message.type) {
        case JXMessageTypeImage: {
            CGSize retSize = self.message.thumbnailImageSize;
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

            [self removeConstraint:self.bubbleWithImageConstraint];

            CGFloat margin = self.leftBubbleMargin.left +
                             self.leftBubbleMargin.right;
            self.bubbleWithImageConstraint =
                    [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                 attribute:NSLayoutAttributeWidth
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1.0
                                                  constant:retSize.width + margin];
            [self addConstraint:self.bubbleWithImageConstraint];

        } break;
        default:
            break;
    }

}

- (void)configureLayoutConstraintsWithModel:(JXMessage *)message {
    if (message.type == JXMessageTypeTips) return;
    if (message.isSender) {
        [self configureSendLayoutConstraints];
    } else {
        [self configureRecvLayoutConstraints];
    }
}

- (void)configureSendLayoutConstraints {
    // avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:JXMessageCellPadding]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-JXMessageCellPadding]];

    self.avatarWidthConstraint =
            [NSLayoutConstraint constraintWithItem:self.avatarView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.avatarView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];

    // name label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.avatarView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:-JXMessageCellPadding]];

    self.nameHeightConstraint =
            [NSLayoutConstraint constraintWithItem:self.nameLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:self.messageNameHeight];
    [self addConstraint:self.nameHeightConstraint];

    // bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.avatarView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:-JXMessageCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];

    // status button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.bubbleView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:-JXMessageCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.bubbleView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

    // activtiy
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.bubbleView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:-JXMessageCellPadding]];

    // hasRead
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.bubbleView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:-JXMessageCellPadding]];
}

- (void)configureRecvLayoutConstraints {
    // avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:JXMessageCellPadding]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:JXMessageCellPadding]];

    self.avatarWidthConstraint =
            [NSLayoutConstraint constraintWithItem:self.avatarView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.avatarView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];

    // name label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.avatarView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:JXMessageCellPadding]];

    self.nameHeightConstraint =
            [NSLayoutConstraint constraintWithItem:self.nameLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:self.messageNameHeight];
    [self addConstraint:self.nameHeightConstraint];

    // bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.avatarView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:JXMessageCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    // activtiy
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.bubbleView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:JXMessageCellPadding]];

}

#pragma mark - Update Constraint

- (void)_updateAvatarViewWidthConstraint {
    if (self.avatarView) {
        [self removeConstraint:self.avatarWidthConstraint];

        self.avatarWidthConstraint =
                [NSLayoutConstraint constraintWithItem:self.avatarView
                                             attribute:NSLayoutAttributeWidth
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeNotAnAttribute
                                            multiplier:0
                                              constant:self.avatarSize];
        [self addConstraint:self.avatarWidthConstraint];
    }
}

- (void)_updateNameHeightConstraint {
    if (self.nameLabel) {
        [self removeConstraint:self.nameHeightConstraint];

        self.nameHeightConstraint =
                [NSLayoutConstraint constraintWithItem:self.nameLabel
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeNotAnAttribute
                                            multiplier:1.0
                                              constant:self.messageNameHeight];
        [self addConstraint:self.nameHeightConstraint];
    }
}

#pragma mark - setter

- (void)updateMessageStatus {
    [super updateMessageStatus];
    self.hasRead.hidden = YES;
    if (self.bubbleView.unReadView) { // 语音消息的未读提示
        self.bubbleView.unReadView.hidden = self.message.isRead;
    }
    
    switch (self.message.status) {
        case JXMessageStatusDownloading: {
            if (self.message.direction == JXMessageDirectionReceive) {
                [self.activity setHidden:NO];
                [self.activity startAnimating];
            }
        } break;
        case JXMessageStatusDownload: {
            if (self.message.type == JXMessageTypeImage || self.message.type == JXMessageTypeVideo) {
                UIImage *image = [UIImage imageWithContentsOfFile:self.message.thumbUrlToDisplay];
                if (image) self.bubbleView.imageView.image = image;
            }
            
        } break;
        case JXMessageStatusSending: {
            self.statusButton.hidden = YES;
            [self.activity setHidden:NO];
            [self.activity startAnimating];
        } break;
        case JXMessageStatusRead:
            self.hasRead.text = JXUIString(@"read");
            self.hasRead.hidden = NO;
            break;
        case JXMessageStatusDelivered:
            self.hasRead.text = JXUIString(@"delivered");
            self.hasRead.hidden = NO;
            break;
        case JXMessageStatusSend: {
            self.hasRead.text = JXUIString(@"sent");
            self.statusButton.hidden = YES;
            [self.activity stopAnimating];
            self.hasRead.hidden = NO;
        } break;
        case JXMessageStatusFailure:
        case JXMessageStatusReject: {
            [self.activity stopAnimating];
            self.statusButton.hidden = NO;
        } break;
        default:
            break;
    }
}

- (void)setMessage:(JXMessage *)message {
    [super setMessage:message];

    self.avatarView.image = message.avatarImage;
    self.nameLabel.text = message.nickname;
    [self updateMessageStatus];
}

- (void)setMessageNameFont:(UIFont *)messageNameFont {
    _messageNameFont = messageNameFont;
    if (self.nameLabel) {
        self.nameLabel.font = _messageNameFont;
    }
}

- (void)setMessageNameColor:(UIColor *)messageNameColor {
    _messageNameColor = messageNameColor;
    if (self.nameLabel) {
        self.nameLabel.textColor = _messageNameColor;
    }
}

- (void)setMessageNameHeight:(CGFloat)messageNameHeight {
    _messageNameHeight = messageNameHeight;
    if (self.nameLabel) {
        [self _updateNameHeightConstraint];
    }
}

- (void)setAvatarSize:(CGFloat)avatarSize {
    _avatarSize = avatarSize;
    if (self.avatarView) {
        [self _updateAvatarViewWidthConstraint];
    }
}

- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius {
    _avatarCornerRadius = avatarCornerRadius;
    if (self.avatarView) {
        self.avatarView.layer.cornerRadius = avatarCornerRadius;
    }
}

- (void)setMessageNameIsHidden:(BOOL)messageNameIsHidden {
    _messageNameIsHidden = messageNameIsHidden;
    if (self.nameLabel) {
        self.nameLabel.hidden = messageNameIsHidden;
    }
}

#pragma mark - public

+ (CGFloat)cellHeightForMessage:(JXMessage *)message {
    if (message.type == JXMessageTypeTips) return 30;
    JXCommonMessageCell *cell = [self appearance];

    CGFloat minHeight = cell.avatarSize + JXMessageCellPadding * 2;
    CGFloat height = cell.messageNameHeight;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        height = 15;
    }
    height += -JXMessageCellPadding + [JXMessageCell cellHeightForMessage:message];
    height = height > minHeight ? height : minHeight;

    return height;
}

@end
