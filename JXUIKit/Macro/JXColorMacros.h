//
//  JXColorMacros.h
//

#ifndef JXUIKit_JXColorMacros_h
#define JXUIKit_JXColorMacros_h

#define JXColorWithRGBA(_R_, _G_, _B_, _A_) \
    [UIColor colorWithRed:_R_ / 255.0 green:_G_ / 255.0 blue:_B_ / 255.0 alpha:_A_]

#define JXColorWithRGB(_R_, _G_, _B_) \
    [UIColor colorWithRed:_R_ / 255.0 green:_G_ / 255.0 blue:_B_ / 255.0 alpha:1.0]

#define JXPureColor(_a_) \
    [UIColor colorWithRed:_a_ / 255.0 green:_a_ / 255.0 blue:_a_ / 255.0 alpha:1.0]

#define JXPureAlphaColor(_a_, _alpha_) \
    [UIColor colorWithRed:_a_ / 255.0 green:_a_ / 255.0 blue:_a_ / 255.0 alpha:_alpha_]

#define JXHexRGB(rgbValue)                                               \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((float)(rgbValue & 0xFF)) / 255.0             \
                    alpha:1.0]

#define JXHexRGBA(rgbValue, _alpha_)                                     \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((float)(rgbValue & 0xFF)) / 255.0             \
                    alpha:_alpha_]

#define kTextViewContentDefaultColor JXPureColor(255.0)    //*输入框 背景颜色
#define kLayerBorderDefaultColor JXPureColor(230.0)        //*输入框 边框颜色
#define kSeprateLineDefaultColor JXPureColor(217.0)        //*分割线
#define kDefaultBlueColor JXColorWithRGB(27.0, 203.0, 197.0)

#define kDefaultBackgroundColor JXPureColor(248.0)    // 通用背景色

#endif
