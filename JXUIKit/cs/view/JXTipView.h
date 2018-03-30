
//
//  JXTipView.h
//  mcs_demo
//
//  Copyright © 2016年 jiaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXTipView : UIView

@property (nonatomic, copy) NSString *contentString;

- (void)addAttributedString:(NSAttributedString *)title withTarget:(id)target andAction:(SEL)selector;


@property (nonatomic, assign) CGFloat margin; // default is 5.f
@property (nonatomic, assign) BOOL showCloseBtn; // default is NO
@property (nonatomic, copy) NSString *identify; // tipview标示
@property (nonatomic, copy) void (^closedComplete)(JXTipView *tipView); // tipview被移除时调用

@end
