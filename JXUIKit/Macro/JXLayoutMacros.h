//
//  JXLayoutMacros.h
//

#ifndef JXUIKit_JXLayoutMacros_h
#define JXUIKit_JXLayoutMacros_h

#define kJXDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define JXSafeAreaBottom (kJXDevice_Is_iPhoneX ? 34.f : 0)

#define JXMinPixels 1.0 / [UIScreen mainScreen].scale
#define JXScreenSize [UIScreen mainScreen].bounds.size

#define JXSystemFont(_fontSize_) [UIFont systemFontOfSize:_fontSize_]
#define JXBoldSystemFont(_fontSize_) [UIFont boldSystemFontOfSize:_fontSize_]
#define JXFontYaHeiOfSize(fontSize) [UIFont fontWithName:@"FZXH1JW--GB1-0" size:fontSize]
#define JXFontSong(fontSize) [UIFont fontWithName:@"SimSun" size:fontSize]
#define JXFontDigital(fontSize) [UIFont fontWithName:@"DS-Digital" size:fontSize]
#define JXFZfontStr @"FZXH1JW--GB1-0"

#define JXDefautContactCellHeight 60

#endif
