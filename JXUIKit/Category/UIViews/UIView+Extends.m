//
//  UIView+Extends.m
//

#import "UIView+Extends.h"
#import <objc/runtime.h>

static char kDTActionHandlerTapBlockKey;
static char kDTActionHandlerTapGestureKey;
static char kDTActionHandlerLongPressBlockKey;
static char kDTActionHandlerLongPressGestureKey;

@implementation UIView (Extends)

- (CGFloat)jx_left {
    return self.frame.origin.x;
}

- (void)setJx_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)jx_top {
    return self.frame.origin.y;
}

- (void)setJx_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)jx_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setJx_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)jx_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setJx_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)jx_centerX {
    return self.center.x;
}

- (void)setJx_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)jx_centerY {
    return self.center.y;
}

- (void)setJx_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)jx_width {
    return self.frame.size.width;
}

- (void)setJx_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)jx_height {
    return self.frame.size.height;
}

- (void)setJx_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)jx_screenX {
    CGFloat x = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        x += view.jx_left;
    }
    return x;
}

- (CGFloat)jx_screenY {
    CGFloat y = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        y += view.jx_top;
    }
    return y;
}

- (CGFloat)jx_screenViewX {
    CGFloat x = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        x += view.jx_left;

        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }

    return x;
}

- (CGFloat)jx_screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.jx_top;

        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}

- (CGRect)jx_screenFrame {
    return CGRectMake(self.jx_screenViewX, self.jx_screenViewY, self.jx_width, self.jx_height);
}

- (CGPoint)jx_origin {
    return self.frame.origin;
}

- (void)setJx_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)jx_size {
    return self.frame.size;
}

- (void)setJx_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)jx_orientationWidth {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
                   ? self.jx_height
                   : self.jx_width;
}

- (CGFloat)jx_orientationHeight {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
                   ? self.jx_width
                   : self.jx_height;
}

- (UIView*)descendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) return self;

    for (UIView* child in self.subviews) {
        UIView* it = [child descendantOrSelfWithClass:cls];
        if (it) return it;
    }

    return nil;
}

- (UIView*)ancestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;

    } else if (self.superview) {
        return [self.superview ancestorOrSelfWithClass:cls];

    } else {
        return nil;
    }
}

- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (CGPoint)offsetFromView:(UIView*)otherView {
    CGFloat x = 0.0f, y = 0.0f;
    for (UIView* view = self; view && view != otherView; view = view.superview) {
        x += view.jx_left;
        y += view.jx_top;
    }
    return CGPointMake(x, y);
}

- (void)setTapActionWithBlock:(void (^)(void))block {
    UITapGestureRecognizer* gesture =
            objc_getAssociatedObject(self, &kDTActionHandlerTapGestureKey);

    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                        action:@selector(__handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerTapGestureKey, gesture,
                                 OBJC_ASSOCIATION_RETAIN);
    }

    objc_setAssociatedObject(self, &kDTActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForTapGesture:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        void (^action)(void) = objc_getAssociatedObject(self, &kDTActionHandlerTapBlockKey);

        if (action) {
            action();
        }
    }
}

- (void)setLongPressActionWithBlock:(void (^)(UIGestureRecognizer*))block {
    UILongPressGestureRecognizer* gesture =
            objc_getAssociatedObject(self, &kDTActionHandlerLongPressGestureKey);

    if (!gesture) {
        gesture = [[UILongPressGestureRecognizer alloc]
                initWithTarget:self
                        action:@selector(__handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerLongPressGestureKey, gesture,
                                 OBJC_ASSOCIATION_RETAIN);
    }

    objc_setAssociatedObject(self, &kDTActionHandlerLongPressBlockKey, block,
                             OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForLongPressGesture:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        void (^action)(UIGestureRecognizer*) =
                objc_getAssociatedObject(self, &kDTActionHandlerLongPressBlockKey);

        if (action) {
            action(gesture);
        }
    }
}

- (void)showLayerBorder {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)showLayerBorderWithColor:(UIColor*)color {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = color.CGColor;
}

- (void)addLineToViewAtPosition:(UIViewAddLinePosition)position withLineColor:(UIColor*)lineColor {
    UIView* line = [[UIView alloc] init];
    line.backgroundColor = lineColor;
    [self addSubview:line];

    CGFloat minPixels =  1.0/[UIScreen mainScreen].scale;
    switch (position) {
        case UIViewAddLinePositionBottom: {
            line.frame = CGRectMake(0, self.jx_height - minPixels, self.jx_width, minPixels);
            line.autoresizingMask =
                    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        } break;
        case UIViewAddLinePositionTop: {
            line.frame = CGRectMake(0, 0, self.jx_width, minPixels);
            line.autoresizingMask =
                    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        } break;

        default:
            break;
    }
}
@end
