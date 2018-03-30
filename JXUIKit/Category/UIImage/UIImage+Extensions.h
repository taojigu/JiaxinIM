//
//  UIImage+Extensions.h
//

#import "UIImage+animatedGIF.h"

@interface UIImage (Extensions)

+ (NSData *)autoScaleImage:(UIImage *)image ToSize:(NSInteger)sizeKB;

/**
 *  创建纯色的背景图
 *
 *  @param color 背景图的颜色
 *
 *  @return 背景图
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  修正图片方向的方法
 *
 *  @return 修正后的图片
 */
- (UIImage *)fixOrientation;


/**
 获取图片的主色调

 @return 图片的主色调
 */
- (UIColor*)mostColor;

@end
