//
//  JXBubbleView.m
//

#import "JXBubbleView.h"

#import "JXBubbleView+Image.h"
#import "JXBubbleView+Location.h"
#import "JXBubbleView+Text.h"
#import "JXBubbleView+Voice.h"

@interface JXBubbleView ()

@property(nonatomic) NSLayoutConstraint *marginTopConstraint;
@property(nonatomic) NSLayoutConstraint *marginBottomConstraint;
@property(nonatomic) NSLayoutConstraint *marginLeftConstraint;
@property(nonatomic) NSLayoutConstraint *marginRightConstraint;

@end

@implementation JXBubbleView

@synthesize margin = _margin;

- (instancetype)initWithMargin:(UIEdgeInsets)margin isSender:(BOOL)isSender {
    if (self = [super init]) {
        _isSender = isSender;
        _margin = margin;

        _marginConstraints = [NSMutableArray array];
    }

    return self;
}

#pragma mark - Setup Constraints

- (void)_setupBackgroundImageViewConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0]];
}

#pragma mark - getter

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundImageView.userInteractionEnabled = YES;
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundImageView];
        [self _setupBackgroundImageViewConstraints];
    }

    return _backgroundImageView;
}

@end
