//
//  JXTipView.m
//  mcs_demo
//
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import "JXTipView.h"
#import "JXSDKHelper.h"
#import <CoreText/CoreText.h>

@interface JXTipView ()

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, assign) CGFloat maxLeftMargin;

@end

@implementation JXTipView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        [self setupSubviews];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    if (self.closedComplete) {
        self.closedComplete(self);
    }
}

- (void)setupSubviews {
    _margin = 5.f;
    [self addSubview:self.label];
    [self addSubview:self.closeBtn];
    NSDictionary *views = @{ @"lb" : self.label, @"cb" : self.closeBtn };

    [self addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-8-[lb]-(>=0)-[cb]-0-|"
                                                     options:0
                                                     metrics:nil
                                                       views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[cb]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lb]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

- (void)setShowCloseBtn:(BOOL)showCloseBtn {
    _showCloseBtn = showCloseBtn;
    self.closeBtn.hidden = !_showCloseBtn;
}

- (void)setContentString:(NSString *)contentString {
    _contentString = contentString.copy;
    self.label.text = _contentString;
    NSDictionary *dict = @{NSFontAttributeName : _label.font};
    CGSize size = [_contentString boundingRectWithSize:_label.jx_size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:dict
                                               context:nil]
                          .size;
    self.maxLeftMargin = size.width + self.margin + 5;
}

- (void)addAttributedString:(NSAttributedString *)title
                 withTarget:(id)target
                  andAction:(SEL)selector {
    UIButton *button = [self creatButtonWithTitle:title];
    NSAssert([target respondsToSelector:selector], @"target not found");
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addCustomButton:button];
}

- (UIButton *)creatButtonWithTitle:(NSAttributedString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setAttributedTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (void)addCustomButton:(UIButton *)button {
    [self addSubview:button];
    CGFloat btnWidth = 30;
    if (IOSVersion >= 10) {
        btnWidth = 40;
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:self.maxLeftMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:btnWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    self.maxLeftMargin += 40;
}

- (NSString *)identify {
    if (!_identify.length) {
        _identify = @"";
    }
    return _identify;
}

- (void)close {
    [UIView animateWithDuration:0.25
            animations:^{
                self.alpha = 0;
            }
            completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.textColor = [UIColor blackColor];
        _label.font = [UIFont systemFontOfSize:15];
        _label.numberOfLines = 2;
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeBtn setImage:JXChatImage(@"cancel") forState:UIControlStateNormal];
        [_closeBtn setImage:JXChatImage(@"cancel_selected") forState:UIControlStateHighlighted];
        _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [_closeBtn addTarget:self
                          action:@selector(close)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
