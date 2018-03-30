//
//  JXBubbleView+Image.m
//

#import "JXBubbleView+Image.h"

@implementation JXBubbleView (Image)

#pragma mark - private

- (void)_setupImageBubbleMarginConstraints {
    NSLayoutConstraint *marginTopConstraint =
            [NSLayoutConstraint constraintWithItem:self.imageView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:self.margin.top];
    NSLayoutConstraint *marginBottomConstraint =
            [NSLayoutConstraint constraintWithItem:self.imageView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:-self.margin.bottom];
    NSLayoutConstraint *marginLeftConstraint =
            [NSLayoutConstraint constraintWithItem:self.imageView
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.backgroundImageView
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                          constant:-self.margin.right];
    NSLayoutConstraint *marginRightConstraint =
            [NSLayoutConstraint constraintWithItem:self.imageView
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

    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.progressLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.imageView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.progressLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.imageView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.progressLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.imageView
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:0]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.progressLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.imageView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:0]];

    [self addConstraints:self.marginConstraints];
}

- (void)_setupImageBubbleConstraints {
    [self _setupImageBubbleMarginConstraints];
}

#pragma mark - public

- (void)setupImageBubbleView {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.backgroundImageView addSubview:self.imageView];

    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressLabel setBackgroundColor:[UIColor clearColor]];
    [self.progressLabel setTextColor:[UIColor whiteColor]];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.font = [UIFont boldSystemFontOfSize:18];
    self.progressLabel.userInteractionEnabled = NO;
    [self.imageView addSubview:self.progressLabel];

    [self _setupImageBubbleConstraints];
}

- (void)updateImageMargin:(UIEdgeInsets)margin {
    if (_margin.top == margin.top && _margin.bottom == margin.bottom &&
        _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;

    [self removeConstraints:self.marginConstraints];
    [self _setupImageBubbleMarginConstraints];
}

@end
