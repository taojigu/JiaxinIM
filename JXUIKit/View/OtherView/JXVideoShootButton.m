//
//  JXVideoShootButton.m
//  JXUIKit
//
//  Created by raymond on 16/11/11.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXVideoShootButton.h"
#import "JXSDKHelper.h"

const CGFloat ScaleButtonCircleRadius = 120.f;

#define UIColorFromRGB(rgbValue)                                         \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((float)(rgbValue & 0xFF)) / 255.0             \
                    alpha:1.0]

@implementation JXVideoShootButton {
    CALayer *_effectiveLayer;
    WKState _state;
    CGFloat _scaleButtonCircleRadius;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    _scaleButtonCircleRadius = rect.size.height * 0.5 - 10;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:_scaleButtonCircleRadius
                                                    startAngle:-M_PI
                                                      endAngle:M_PI
                                                     clockwise:YES];
    [[UIColor yellowColor] setStroke];
    [path stroke];
}

- (void)setupUI {
    self.backgroundColor = [UIColor blackColor];

    [self addSubview:self.label];
    [self addSubview:self.cancelBtn];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelBtn
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelBtn
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:-8]];

    UILongPressGestureRecognizer *panGesture =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:panGesture];
    panGesture.minimumPressDuration = 0.5;

    UITapGestureRecognizer *tapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    [self.cancelBtn addGestureRecognizer:tapGesture];
    [panGesture requireGestureRecognizerToFail:tapGesture];
}

- (void)setTitle:(NSString *)title {
    _label.text = title;
}

- (void)panAction:(UILongPressGestureRecognizer *)ges {
    switch (ges.state) {
        case UIGestureRecognizerStateBegan: {
            _state = WKStateIn;
            self.stateChangeBlock(WKStateBegin);

            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [ges locationInView:self];

            if (![self circleContainsPoint:point]) {
                _state = WKStateOut;
                self.stateChangeBlock(WKStateOut);
            } else {
                self.stateChangeBlock(WKStateIn);
                _state = WKStateIn;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (_state == WKStateIn) {
                self.stateChangeBlock(WKStateFinish);
            } else {
                self.stateChangeBlock(WKStateCancle);
            }
            break;
        }
        case UIGestureRecognizerStateFailed: {
            NSLog(@"failed");
            self.stateChangeBlock(WKStateCancle);
            break;
        }
        default:
            break;
    }
}

- (void)cancel {
    if (self.stateChangeBlock) {
        self.stateChangeBlock(WKStateCancle);
    }
}

- (void)disappearAnimation {
    CABasicAnimation *animation_scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation_scale.toValue = @1.5;
    CABasicAnimation *animation_opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation_opacity.toValue = @0;
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    aniGroup.duration = 0.2;
    aniGroup.animations = @[ animation_scale, animation_opacity ];
    aniGroup.fillMode = kCAFillModeForwards;
    aniGroup.removedOnCompletion = NO;
    [_label.layer addAnimation:aniGroup forKey:@"start1"];
}

- (void)appearAnimation {
    CABasicAnimation *animation_scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation_scale.toValue = @1;
    CABasicAnimation *animation_opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation_opacity.toValue = @1;
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    aniGroup.duration = 0.2;
    aniGroup.animations = @[ animation_scale, animation_opacity ];
    aniGroup.fillMode = kCAFillModeForwards;
    aniGroup.removedOnCompletion = NO;
    [_label.layer addAnimation:aniGroup forKey:@"reset1"];
}

- (CGFloat)radius {
    return _scaleButtonCircleRadius;
}

- (BOOL)circleContainsPoint:(CGPoint)point {
    CGRect circleRect = self.bounds;
    return CGRectContainsPoint(circleRect, point);
}

#pragma mark - lazy load

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.backgroundColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = JXUIString(@"hold to film");
        [_label sizeToFit];
        _label.textColor = [UIColor lightGrayColor];
    }
    return _label;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelBtn setImage:JXChatImage(@"cancel") forState:UIControlStateNormal];
        [_cancelBtn setBackgroundColor:[UIColor clearColor]];
        _cancelBtn.layer.cornerRadius = _cancelBtn.currentImage.size.width * 0.5;
        _cancelBtn.clipsToBounds = YES;
        [_cancelBtn sizeToFit];
    }
    return _cancelBtn;
}

@end
