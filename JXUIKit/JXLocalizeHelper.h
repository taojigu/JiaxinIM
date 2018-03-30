//
// JXLocalizeHelper.h
//

#import <Foundation/Foundation.h>

#define LocalizationSetLanguage(language) \
    [[JXLocalizeHelper sharedLocalSystem] setLanguage:(language)]

#define JXUIString(key) [[JXLocalizeHelper sharedLocalSystem] localizedStringForKey:(key)]

@interface JXLocalizeHelper : NSObject

// a singleton:
+ (JXLocalizeHelper*)sharedLocalSystem;

// this gets the string localized:
- (NSString*)localizedStringForKey:(NSString*)key;

// set a new language:
- (void)setLanguage:(NSString*)lang;

- (NSString *)getLanguage;

@end
