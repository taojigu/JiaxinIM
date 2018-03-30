//
//  UIImage+Extensions.m
//

#import "UIImage+Extensions.h"

static void RGBtoHSV(float r, float g, float b, float *h, float *s, float *v) {
    float min, max, delta;
    min = MIN(r, MIN(g, b));
    max = MAX(r, MAX(g, b));
    *v = max;    // v
    delta = max - min;
    if (max != 0)
        *s = delta / max;    // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if (r == max)
        *h = (g - b) / delta;    // between yellow & magenta
    else if (g == max)
        *h = 2 + (b - r) / delta;    // between cyan & yellow
    else
        *h = 4 + (r - g) / delta;    // between magenta & cyan
    *h *= 60;                        // degrees
    if (*h < 0) *h += 360;
}

@implementation UIImage (Extensions)

+ (NSData *)autoScaleImage:(UIImage *)image ToSize:(NSInteger)sizeKB {
    // 发送内容包含图片，先判断是否需要压缩，然后再发送
    NSData *dataImage = UIImageJPEGRepresentation(image, 1.0);
    NSUInteger sizeOrigin = [[dataImage
            base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] length];
    double scale = (double)sizeKB * 1024 / sizeOrigin;

    // 图片大于size要先进行压缩
    if (scale < 1) {
        double q = sqrt(scale);
        CGSize sizeImage = [image size];
        CGFloat iwidthSmall = sizeImage.width * q;
        CGFloat iheightSmall = sizeImage.height * q;

        CGSize itemSizeSmall = CGSizeMake(iwidthSmall, iheightSmall);

        UIGraphicsBeginImageContext(itemSizeSmall);
        CGRect imageRectSmall = CGRectMake(0.0f, 0.0f, itemSizeSmall.width, itemSizeSmall.height);
        [image drawInRect:imageRectSmall];
        UIImage *SmallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSData *dataImageSend = UIImageJPEGRepresentation(SmallImage, 0.9);
        dataImage = dataImageSend;
    }
    return dataImage;
}

/**
 *  创建纯色的背景图
 *
 *  @param color 背景图的颜色
 *
 *  @return 背景图
 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)fixOrientation {
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(
            NULL, self.size.width, self.size.height, CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width),
                               self.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height),
                               self.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/*
- (UIColor*)mostColor {

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif

    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize=CGSizeMake(50, 50);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);

    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);



    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);

    if (data == NULL) return nil;

    NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];

    for (int x=0; x<thumbSize.width; x++) {
        for (int y=0; y<thumbSize.height; y++) {

            int offset = 4*(x*y);

            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha =  data[offset+3];

            NSArray *clr=@[@(red),@(green),@(blue),@(alpha)];
            [cls addObject:clr];

        }
    }
    CGContextRelease(context);


    //第三步 找到出现次数最多的那个颜色
    NSEnumerator *enumerator = [cls objectEnumerator];
    NSArray *curColor = nil;

    NSArray *MaxColor=nil;
    NSUInteger MaxCount=0;

    while ( (curColor = [enumerator nextObject]) != nil )
    {
        NSUInteger tmpCount = [cls countForObject:curColor];

        if ( tmpCount < MaxCount ) continue;

        MaxCount=tmpCount;
        MaxColor=curColor;

    }

    return [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1]
intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
}
 */

- (UIColor *)mostColor {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif

    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize = CGSizeMake(50, 50);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, thumbSize.width, thumbSize.height,
                                                 8,    // bits per component
                                                 thumbSize.width * 4, colorSpace, bitmapInfo);

    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);

    //第二步 取每个点的像素值
    unsigned char *data = CGBitmapContextGetData(context);

    if (data == NULL) return nil;
    NSArray *MaxColor = nil;
    // NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];
    float maxScore = 0;
    for (int x = 0; x < thumbSize.width * thumbSize.height; x++) {
        int offset = 4 * x;

        int red = data[offset];
        int green = data[offset + 1];
        int blue = data[offset + 2];
        int alpha = data[offset + 3];

        if (alpha < 25) continue;

        float h, s, v;
        RGBtoHSV(red, green, blue, &h, &s, &v);

        float y = MIN(abs(red * 2104 + green * 4130 + blue * 802 + 4096 + 131072) >> 13, 235);
        y = (y - 16) / (235 - 16);
        if (y > 0.9) continue;

        float score = (s + 0.1) * x;
        if (score > maxScore) {
            maxScore = score;
        }
        MaxColor = @[ @(red), @(green), @(blue), @(alpha) ];
        //[cls addObject:clr];
    }
    CGContextRelease(context);

    return [UIColor colorWithRed:([MaxColor[0] intValue] / 255.0f)
                           green:([MaxColor[1] intValue] / 255.0f)
                            blue:([MaxColor[2] intValue] / 255.0f)
                           alpha:([MaxColor[3] intValue] / 255.0f)];
}

@end
