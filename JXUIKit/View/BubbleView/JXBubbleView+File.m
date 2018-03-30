//
//  JXBubbleView+File.m
//  JXUIKit
//
//  Created by raymond on 16/7/21.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXBubbleView+File.h"

@implementation JXBubbleView (File)

- (void)setupFileBubbleView {
    // fileNameLabel
    self.fileNameLabel = [[UILabel alloc] init];
    self.fileNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.fileNameLabel.numberOfLines = 0;
    [self.backgroundImageView addSubview:self.fileNameLabel];

    // fileSizeLabel
    self.fileSizeLabel = [[UILabel alloc] init];
    self.fileSizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImageView addSubview:self.fileSizeLabel];

    // fileIconView
    self.fileIconView = [[UIImageView alloc] initWithImage:JXChatImage(@"file_icon")
                                          highlightedImage:JXChatImage(@"file_icon_click")];
    self.fileIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.fileIconView.userInteractionEnabled = YES;
//    self.fileIconView.highlighted = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileIconViewAction:)];
    [self.fileIconView addGestureRecognizer:tap];
    [self.backgroundImageView addSubview:self.fileIconView];

    // fileProgressView
    self.fileProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.fileProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.fileProgressView.progressTintColor = [UIColor blueColor];
    self.fileProgressView.trackTintColor = [UIColor whiteColor];
    self.fileProgressView.hidden = YES;
    [self.backgroundImageView addSubview:self.fileProgressView];

    // precentLabel
    self.precentLabel = [[UILabel alloc] init];
    self.precentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.precentLabel.font = [UIFont systemFontOfSize:10.f];
    self.precentLabel.textColor = [UIColor blueColor];
    self.precentLabel.text = @"0%";
    self.precentLabel.hidden = YES;
    [self.backgroundImageView addSubview:self.precentLabel];

    [self _setupFileBubbleMarginConstraints];
}

- (void)_setupFileBubbleMarginConstraints {
    [self.marginConstraints removeAllObjects];

    // fileNameLabel
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileNameLabel
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1
                                                    constant:self.margin.top]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileNameLabel
                                                   attribute:NSLayoutAttributeLeading
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeLeading
                                                  multiplier:1
                                                    constant:self.margin.left]];

    // fileSizeLabel
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.fileSizeLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.fileNameLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileSizeLabel
                                                   attribute:NSLayoutAttributeLeading
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeLeading
                                                  multiplier:1
                                                    constant:self.margin.left]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileSizeLabel
                                                   attribute:NSLayoutAttributeBottom
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeBottom
                                                  multiplier:1
                                                    constant:-self.margin.bottom]];

    // fileIconView
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileIconView
                                                   attribute:NSLayoutAttributeCenterY
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeCenterY
                                                  multiplier:1
                                                    constant:0]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.fileIconView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.fileNameLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:self.margin.left]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileIconView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.backgroundImageView
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1
                                                    constant:-self.margin.right]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileIconView
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:1
                                                    constant:30]];
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.fileIconView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.fileIconView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0]];

    // fileProgressView
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileProgressView
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:1
                                                    constant:30]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileProgressView
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.fileIconView
                                                   attribute:NSLayoutAttributeCenterX
                                                  multiplier:1
                                                    constant:0]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.fileProgressView
                                                   attribute:NSLayoutAttributeCenterY
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.fileIconView
                                                   attribute:NSLayoutAttributeCenterY
                                                  multiplier:1
                                                    constant:0]];
    // precentLabel
    [self.marginConstraints addObject:[NSLayoutConstraint constraintWithItem:self.precentLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.fileProgressView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:0]];
    [self.marginConstraints
            addObject:[NSLayoutConstraint constraintWithItem:self.precentLabel
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self.fileProgressView
                                                   attribute:NSLayoutAttributeCenterX
                                                  multiplier:1
                                                    constant:0]];
    [self addConstraints:self.marginConstraints];
}

- (void)updateFileMargin:(UIEdgeInsets)margin {
    if (_margin.top == margin.top && _margin.bottom == margin.bottom &&
        _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;

    [self removeConstraints:self.marginConstraints];
    [self _setupFileBubbleMarginConstraints];
}

- (void)fileIconViewAction:(UIGestureRecognizer *)gesture {
    if (self.fileIconViewTapBlock) {
        self.fileIconViewTapBlock();
    }
}

@end
