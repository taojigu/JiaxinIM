//
//  JXBubbleView+Rich.m
//

#import "JXBubbleView+RichText.h"

@implementation JXBubbleView (RichText)

- (void)setupRichBubbleView {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont systemFontOfSize:16.f];
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [UIColor blackColor];
    [self.backgroundImageView addSubview:self.titleLabel];

    self.goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 0, 100, 100)];

    self.goodImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.goodImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(goodImageViewTapAction:)];
    [self.goodImageView addGestureRecognizer:tapRecognizer];
    [self.backgroundImageView addSubview:self.goodImageView];

    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceLabel.font = [UIFont systemFontOfSize:14.f];
    self.priceLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.priceLabel.numberOfLines = 0;
    self.priceLabel.textColor = [UIColor redColor];
    [self.backgroundImageView addSubview:self.priceLabel];

    NSString *btnText = self.isSender ? JXUIString(@"send link") : JXUIString(@"open link");
    NSMutableAttributedString *str =
            [[NSMutableAttributedString alloc] initWithString:btnText];
    NSRange strRange = {0, [str length]};
    [str addAttribute:NSForegroundColorAttributeName
                   value:JXColorWithRGB(36, 156, 189)
                   range:strRange];
    [str addAttribute:NSUnderlineStyleAttributeName
                   value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                   range:strRange];
    self.linkBtn = [[UIButton alloc] init];
    self.linkBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.linkBtn.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [self.linkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.linkBtn setAttributedTitle:str forState:UIControlStateNormal];
    self.linkBtn.layer.borderColor = JXColorWithRGB(255, 0, 0).CGColor;
    [self.linkBtn setBackgroundImage:JXChatImage(@"message_link") forState:UIControlStateNormal];
    [self.linkBtn addTarget:self
                      action:@selector(sendLink)
            forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundImageView addSubview:self.linkBtn];

    [self _setupRichBubbleConstraints];
}

- (void)_setupRichBubbleConstraints {
    [self _setupRichBubbleMarginConstraints];
}

- (void)_setupRichBubbleMarginConstraints {
    [self.marginConstraints removeAllObjects];

    // titleLabel
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1.0
                                                    constant:self.margin.top]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                   attribute:NSLayoutAttributeLeft
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeLeft
                                                  multiplier:1.0
                                                    constant:self.margin.left]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0
                                                    constant:-self.margin.right]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:40]];

    // goodImageView
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.goodImageView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.titleLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:self.margin.top]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.goodImageView
                                                   attribute:NSLayoutAttributeLeft
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeLeft
                                                  multiplier:1.0
                                                    constant:self.margin.left]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.goodImageView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0
                                                    constant:-self.margin.right]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.goodImageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:150]];
    // priceLabel
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.priceLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.goodImageView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:self.margin.top]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.priceLabel
                                                   attribute:NSLayoutAttributeLeft
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeLeft
                                                  multiplier:1.0
                                                    constant:self.margin.left]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.priceLabel
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0
                                                    constant:-self.margin.right]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.priceLabel
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:20]];
    // linkBtn
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.linkBtn
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.priceLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:self.margin.top]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.linkBtn
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeCenterX
                                                  multiplier:1.0
                                                    constant:0]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.linkBtn
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:150]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.linkBtn
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:20]];

    [self addConstraints:self.marginConstraints];
}

- (void)updateRichMargin:(UIEdgeInsets)margin {
    if (_margin.top == margin.top && _margin.bottom == margin.bottom &&
        _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;

    [self removeConstraints:self.marginConstraints];
    [self _setupRichBubbleMarginConstraints];
}

- (void)sendLink {
    if (self.richCellLinkBtnTapBlock) {
        self.richCellLinkBtnTapBlock();
    }
}

- (void)goodImageViewTapAction:(UITapGestureRecognizer *)tapRecognizer {
    if (self.richCellImageTapBlock) {
        self.richCellImageTapBlock();
    }
}

@end
