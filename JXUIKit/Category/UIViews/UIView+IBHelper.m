//
//  UIView+IBHelper.m
//

#import "UIView+IBHelper.h"

@implementation UIView (IBHelper)

+ (instancetype)createViewFromXib {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][0];
}

+ (UINib *)viewNib {
    return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

@end
