//
//  JXBubbleView+Video.m
//  JXUIKit
//
//  Created by raymond on 16/11/7.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXBubbleView+Video.h"

@implementation JXBubbleView (Video)

#pragma mark - private

- (void)_setupVideoBubbleMarginConstraints {
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
    NSDictionary *views = @{ @"vsl" : self.videoSizeLabel, @"dl" : self.durationLabel };
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.videoLogoView
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.imageView
                                                   attribute:NSLayoutAttributeCenterX
                                                  multiplier:1
                                                    constant:0]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.videoLogoView
                                                   attribute:NSLayoutAttributeCenterY
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.imageView
                                                   attribute:NSLayoutAttributeCenterY
                                                  multiplier:1
                                                    constant:0]];
    [self.marginConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[vsl]-4-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    [self.marginConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[dl]-4-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    [self.marginConstraints
            addObjectsFromArray:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"H:|-4-[vsl]-(>=8)-[dl]-4-|"
                                                            options:0
                                                            metrics:nil
                                                              views:views]];
    [self addConstraints:self.marginConstraints];
}

- (void)_setupVideoBubbleConstraints {
    [self _setupVideoBubbleMarginConstraints];
}

#pragma mark - public

- (void)setupVideoBubbleView {
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

    self.videoLogoView = [[UIImageView alloc] initWithImage:JXChatImage(@"play")];
    self.videoLogoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView addSubview:self.videoLogoView];

    self.videoSizeLabel = [[UILabel alloc] init];
    self.videoSizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoSizeLabel.textColor = [UIColor whiteColor];
    self.videoSizeLabel.font = [UIFont systemFontOfSize:12];
    [self.imageView addSubview:self.videoSizeLabel];

    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.font = [UIFont systemFontOfSize:12];
    [self.imageView addSubview:self.durationLabel];

    [self _setupVideoBubbleConstraints];
}

- (void)updateVideoMargin:(UIEdgeInsets)margin {
    if (_margin.top == margin.top && _margin.bottom == margin.bottom &&
        _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;

    [self removeConstraints:self.marginConstraints];
    [self _setupVideoBubbleMarginConstraints];
}

@end
