//
//  JXAppMacros.h
//

#import "JXColorMacros.h"
#import "JXLayoutMacros.h"

#ifndef JXUIKit_JXMacros_h
#define JXUIKit_JXMacros_h

#ifdef DEBUG
#define JXDebugAssert(condition)         \
    @try {                               \
        NSAssert((condition), @" ");     \
    } @catch (NSException * exception) { \
    }
#else
#define JXDebugAssert(condition)
#endif

#ifdef DEBUG
#define JXLog(format, ...)                                                                 \
    do {                                                                                   \
        fprintf(stdout, "<%s : %d> %s\n",                                                  \
                [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
                __LINE__, __func__);                                                       \
        (NSLog)((format), ##__VA_ARGS__);                                                  \
    } while (0)
#else
#define JXLog(...)
#endif

#define WS(p) __weak __typeof(&*self) p = self;
#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;
#define DEPRECATED(description) __attribute__((deprecated(description)))

#define IOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define AppBundleIdentifier [[NSBundle mainBundle] bundleIdentifier]
#define AppVersion \
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define kDefaultNotificationCenter [NSNotificationCenter defaultCenter]
#define JXUserDefault [NSUserDefaults standardUserDefaults]
#define JXImage(a) [UIImage imageNamed:a]
#define JXChatImage(a) [UIImage imageNamed:[NSString stringWithFormat:@"JXUIResources.bundle/%@",a]]
#define JXSharedAppDelegate (AppDelegate *)[UIApplication sharedApplication].delegate

#define JXColorRGB(r, g, b) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1]
#define JXColorRGBA(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]
#define JXColor16RGB(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

#endif
