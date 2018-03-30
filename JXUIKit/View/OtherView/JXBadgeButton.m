//
//  JXBadgeButton.m
//  JXUIKit
//
//  Created by raymond on 16/11/15.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXBadgeButton.h"
#import "JXMacros.h"
#import "NSString+Extends.h"
#import "UIView+Extends.h"

@interface JXBadgeButton ()

@property(nonatomic, strong) UIButton *badgeView;

@end

@implementation JXBadgeButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSubviews];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeView.frame = CGRectMake(self.jx_width - 10, -4, 16, 16);
}

- (void)setupSubviews {
    [self addSubview:self.badgeView];
}

#pragma mark - public

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue.copy;
    if (![badgeValue isPureInt]) return;
    self.badgeView.hidden = badgeValue.integerValue <= 0;
    [self.badgeView setTitle:badgeValue forState:UIControlStateNormal];
}

#pragma mark - lazy load

- (UIButton *)badgeView {
    if (!_badgeView) {
        _badgeView = [[UIButton alloc] init];
        [_badgeView setBackgroundImage:JXChatImage(@"corner_uiclick")
                              forState:UIControlStateNormal];
        [_badgeView setBackgroundColor:JXColorWithRGB(38, 165, 239)];
        [_badgeView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _badgeView.titleLabel.font = [UIFont systemFontOfSize:10];
        _badgeView.layer.cornerRadius = 8;
        _badgeView.layer.masksToBounds = YES;
        _badgeView.hidden = YES;
        _badgeView.userInteractionEnabled = NO;
    }
    return _badgeView;
}

@end
