//
//  JXBubbleView+Voice.m
//

#import "JXBubbleView+Voice.h"

#define ISREAD_VIEW_SIZE 10.f

@implementation JXBubbleView (Voice)

#pragma mark - private

- (void)_setupVoiceBubbleMarginConstraints {
    [self.marginConstraints removeAllObjects];

    // image view
    NSLayoutConstraint *imageWithMarginTopConstraint =
            [NSLayoutConstraint constraintWithItem:self.voiceImageView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:self.margin.top];
    NSLayoutConstraint *imageWithMarginBottomConstraint =
            [NSLayoutConstraint constraintWithItem:self.voiceImageView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:-self.margin.bottom];
    [self.marginConstraints addObject:imageWithMarginTopConstraint];
    [self.marginConstraints addObject:imageWithMarginBottomConstraint];

    // duration label
    NSLayoutConstraint *durationWithMarginTopConstraint =
            [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:self.margin.top];
    NSLayoutConstraint *durationWithMarginBottomConstraint =
            [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:-self.margin.bottom];
    [self.marginConstraints addObject:durationWithMarginTopConstraint];
    [self.marginConstraints addObject:durationWithMarginBottomConstraint];

    if (self.isSender) {
        NSLayoutConstraint *imageWithMarginRightConstraint =
                [NSLayoutConstraint constraintWithItem:self.voiceImageView
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.backgroundImageView
                                             attribute:NSLayoutAttributeRight
                                            multiplier:1.0
                                              constant:-self.margin.right];
        [self.marginConstraints addObject:imageWithMarginRightConstraint];

        NSLayoutConstraint *durationRightConstraint =
                [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.voiceImageView
                                             attribute:NSLayoutAttributeLeft
                                            multiplier:1.0
                                              constant:-JXMessageCellPadding];
        [self.marginConstraints addObject:durationRightConstraint];

        NSLayoutConstraint *durationLeftConstraint =
                [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.backgroundImageView
                                             attribute:NSLayoutAttributeLeft
                                            multiplier:1.0
                                              constant:self.margin.left];
        [self.marginConstraints addObject:durationLeftConstraint];
    } else {
        NSLayoutConstraint *imageWithMarginLeftConstraint =
                [NSLayoutConstraint constraintWithItem:self.voiceImageView
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.backgroundImageView
                                             attribute:NSLayoutAttributeLeft
                                            multiplier:1.0
                                              constant:self.margin.left];
        [self.marginConstraints addObject:imageWithMarginLeftConstraint];

        NSLayoutConstraint *durationLeftConstraint =
                [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.voiceImageView
                                             attribute:NSLayoutAttributeRight
                                            multiplier:1.0
                                              constant:JXMessageCellPadding];
        [self.marginConstraints addObject:durationLeftConstraint];

        NSLayoutConstraint *durationRightConstraint =
                [NSLayoutConstraint constraintWithItem:self.voiceDurationLabel
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.backgroundImageView
                                             attribute:NSLayoutAttributeRight
                                            multiplier:1.0
                                              constant:-self.margin.right];
        [self.marginConstraints addObject:durationRightConstraint];

        [self.marginConstraints
                addObject:[NSLayoutConstraint constraintWithItem:self.unReadView
                                                       attribute:NSLayoutAttributeRight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.backgroundImageView
                                                       attribute:NSLayoutAttributeRight
                                                      multiplier:1.0
                                                        constant:ISREAD_VIEW_SIZE / 2]];
        [self.marginConstraints
                addObject:[NSLayoutConstraint constraintWithItem:self.unReadView
                                                       attribute:NSLayoutAttributeLeft
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.backgroundImageView
                                                       attribute:NSLayoutAttributeRight
                                                      multiplier:1.0
                                                        constant:-ISREAD_VIEW_SIZE / 2]];
        [self.marginConstraints
                addObject:[NSLayoutConstraint constraintWithItem:self.unReadView
                                                       attribute:NSLayoutAttributeCenterY
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.backgroundImageView
                                                       attribute:NSLayoutAttributeCenterY
                                                      multiplier:1.0
                                                        constant:0]];
        [self.marginConstraints
                addObject:[NSLayoutConstraint constraintWithItem:self.unReadView
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:ISREAD_VIEW_SIZE]];
    }

    [self addConstraints:self.marginConstraints];
}

- (void)_setupVoiceBubbleConstraints {
    if (self.isSender) {
        self.unReadView.hidden = YES;
    }
    [self _setupVoiceBubbleMarginConstraints];
}

#pragma mark - public

- (void)setupVoiceBubbleView {
    self.voiceImageView = [[UIImageView alloc] init];
    self.voiceImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.voiceImageView.userInteractionEnabled = YES;
    self.voiceImageView.backgroundColor = [UIColor clearColor];
    self.voiceImageView.animationDuration = 1;
    [self.backgroundImageView addSubview:self.voiceImageView];

    self.voiceDurationLabel = [[UILabel alloc] init];
    self.voiceDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.voiceDurationLabel.backgroundColor = [UIColor clearColor];
    [self.backgroundImageView addSubview:self.voiceDurationLabel];

    self.unReadView = [[UIImageView alloc] init];
    self.unReadView.translatesAutoresizingMaskIntoConstraints = NO;
    self.unReadView.layer.cornerRadius = ISREAD_VIEW_SIZE / 2;
    self.unReadView.clipsToBounds = YES;
    self.unReadView.backgroundColor = [UIColor redColor];
    [self.backgroundImageView addSubview:self.unReadView];

    [self _setupVoiceBubbleConstraints];
    self.senderAnimationImages = @[
        JXChatImage(@"voicePlay_send1"),
        JXChatImage(@"voicePlay_send2"),
        JXChatImage(@"voicePlay_send3")
    ];

    self.recevierAnimationImages = @[
        JXChatImage(@"voicePlay_recieve1"),
        JXChatImage(@"voicePlay_recieve2"),
        JXChatImage(@"voicePlay_recieve3")
    ];
}

- (void)updateVoiceMargin:(UIEdgeInsets)margin {
    if (_margin.top == margin.top && _margin.bottom == margin.bottom &&
        _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;

    [self removeConstraints:self.marginConstraints];
    [self _setupVoiceBubbleMarginConstraints];
}

- (void)startPlayVoiceAnimation {
    if (self.isSender) {
        self.voiceImageView.animationImages = self.senderAnimationImages;
    } else {
        self.voiceImageView.animationImages = self.recevierAnimationImages;
    }
    self.unReadView.hidden = YES;
    [self.voiceImageView startAnimating];
}

- (void)stopPlayAnimation {
    [self.voiceImageView stopAnimating];
}

@end
