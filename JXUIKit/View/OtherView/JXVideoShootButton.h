//
//  JXVideoShootButton.h
//  JXUIKit
//
//  Created by raymond on 16/11/11.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WKState) {
    WKStateBegin,
    WKStateIn,
    WKStateOut,
    WKStateCancle,
    WKStateFinish
};

typedef void (^WKStateChangeBlock)(WKState state);

@interface JXVideoShootButton : UIView

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UIButton *cancelBtn;
@property(nonatomic, readonly) CGFloat radius;
@property(nonatomic, copy) WKStateChangeBlock stateChangeBlock;

- (void)disappearAnimation;
- (void)appearAnimation;

- (BOOL)circleContainsPoint:(CGPoint)point;
- (void)setTitle:(NSString *)title;

@end
