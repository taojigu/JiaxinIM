//
//  UIView+IBHelper.h
//

#import <UIKit/UIKit.h>

@interface UIView (IBHelper)
+ (instancetype)createViewFromXib;
+ (UINib *)viewNib;
@end
