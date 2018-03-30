//
//  JXEvalMessageCell.m
//

#import "JXEvalMessageCell.h"

@implementation JXEvalMessageCell

- (BOOL)isCustomBubbleView:(JXMessage *)message {
    return YES;
}

- (void)setCustomMessage:(JXMessage *)message {
    self.bubbleView.textLabel.text = message.textToDisplay;
    self.bubbleView.textLabel.textColor = self.messageTextColor;
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)margin message:(JXMessage *)message {
    [self.bubbleView updateRequestMargin:margin];
    [self updateCellButtonConstraints];
}

- (void)setupCustomBubbleView:(JXMessage *)message {
    [self.bubbleView setupEvalBubbleView];
    self.bubbleView.textLabel.font = self.messageTextFont;

    self.cellButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.cellButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.cellButton.userInteractionEnabled = NO;
    [self.cellButton setTitle:JXUIString(@"evaluate") forState:UIControlStateNormal];
    [self.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cellButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];

    self.cellButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cellButton setBackgroundColor:[UIColor blueColor]];
    self.cellButton.layer.cornerRadius = 5;
    self.cellButton.layer.masksToBounds = YES;
    [self.bubbleView.backgroundImageView addSubview:self.cellButton];

    [self updateCellButtonConstraints];
}

- (void)updateCellButtonConstraints {
    [self.bubbleView.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.cellButton
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.bubbleView.textLabel
                                                   attribute:NSLayoutAttributeBottom
                                                  multiplier:1.0
                                                    constant:10]];
    [self.bubbleView.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.cellButton
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.bubbleView.backgroundImageView
                                                   attribute:NSLayoutAttributeCenterX
                                                  multiplier:1.0
                                                    constant:0]];
    [self.bubbleView.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.cellButton
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:1.0
                                                    constant:100]];
    [self.bubbleView.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.cellButton
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:1.0
                                                    constant:JXEvalButtonHeight]];

    [self.bubbleView addConstraints:self.bubbleView.marginConstraints];
}

+ (CGFloat)cellHeightForMessage:(JXMessage *)message {
    JXCommonMessageCell *cell = [self appearance];

    CGFloat minHeight = cell.avatarSize + JXMessageCellPadding * 2;
    CGFloat height = cell.messageNameHeight;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        height = 15;
    }
    height += -JXMessageCellPadding + [JXCommonMessageCell cellHeightForMessage:message];
    height += JXEvalButtonHeight;
    height = height > minHeight ? height : minHeight;

    return height;
}

@end

@implementation JXBubbleView (Eval)

- (void)setupEvalBubbleView {
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.numberOfLines = 0;
    [self.backgroundImageView addSubview:self.textLabel];

    self.textLabel.font = [UIFont systemFontOfSize:16.f];
    self.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.textLabel.numberOfLines = 0;

    [self _setupEvalBubbleMarginConstraints];
}

- (void)_setupEvalBubbleMarginConstraints {
    NSLayoutConstraint *marginTopConstraint =
            [NSLayoutConstraint constraintWithItem:self.textLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:self.margin.top];
    NSLayoutConstraint *marginBottomConstraint =
            [NSLayoutConstraint constraintWithItem:self.textLabel
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:-JXEvalButtonHeight];
    NSLayoutConstraint *marginLeftConstraint =
            [NSLayoutConstraint constraintWithItem:self.textLabel
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                          constant:-self.margin.right];
    NSLayoutConstraint *marginRightConstraint =
            [NSLayoutConstraint constraintWithItem:self.textLabel
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1.0
                                          constant:self.margin.left];

    [self.marginConstraints removeAllObjects];
    [self.marginConstraints addObject:marginTopConstraint];
    [self.marginConstraints addObject:marginBottomConstraint];
    [self.marginConstraints addObject:marginLeftConstraint];
    [self.marginConstraints addObject:marginRightConstraint];
}

- (void)updateRequestMargin:(UIEdgeInsets)margin {
    if (_margin.top == margin.top && _margin.bottom == margin.bottom &&
        _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;

    [self removeConstraints:self.marginConstraints];
    [self _setupEvalBubbleMarginConstraints];
}

@end
