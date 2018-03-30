//
//  UIView+Extends.h
//

#import <UIKit/UIKit.h>

typedef enum { UIViewAddLinePositionTop, UIViewAddLinePositionBottom } UIViewAddLinePosition;

@interface UIView (Extends)
/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property(nonatomic) CGFloat jx_left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property(nonatomic) CGFloat jx_top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property(nonatomic) CGFloat jx_right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property(nonatomic) CGFloat jx_bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property(nonatomic) CGFloat jx_width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property(nonatomic) CGFloat jx_height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property(nonatomic) CGFloat jx_centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property(nonatomic) CGFloat jx_centerY;

/**
 * Return the x coordinate on the screen.
 */
@property(nonatomic, readonly) CGFloat jx_screenX;

/**
 * Return the y coordinate on the screen.
 */
@property(nonatomic, readonly) CGFloat jx_screenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property(nonatomic, readonly) CGFloat jx_screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property(nonatomic, readonly) CGFloat jx_screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property(nonatomic, readonly) CGRect jx_screenFrame;

/**
 * Shortcut for frame.origin
 */
@property(nonatomic) CGPoint jx_origin;

/**
 * Shortcut for frame.size
 */
@property(nonatomic) CGSize jx_size;

/**
 * Return the width in portrait or the height in landscape.
 */
@property(nonatomic, readonly) CGFloat jx_orientationWidth;

/**
 * Return the height in portrait or the width in landscape.
 */
@property(nonatomic, readonly) CGFloat jx_orientationHeight;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (UIView *)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (UIView *)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;

/**
 Attaches the given block for a single tap action to the receiver.
 @param block The block to execute.
 */
- (void)setTapActionWithBlock:(void (^)(void))block;

/**
 Attaches the given block for a long press action to the receiver.
 @param block The block to execute.
 */
- (void)setLongPressActionWithBlock:(void (^)(UIGestureRecognizer*))block;

- (void)showLayerBorder;

- (void)showLayerBorderWithColor:(UIColor *)color;

/**
 * @param color of the line
 * @param postion  the line postion on the view
 * @return
 */
- (void)addLineToViewAtPosition:(UIViewAddLinePosition)position withLineColor:(UIColor *)lineColor;
@end
