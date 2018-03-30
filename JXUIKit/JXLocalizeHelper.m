//
// LocalizeHelper.m
//
#import "JXLocalizeHelper.h"

// Singleton
static JXLocalizeHelper* SingleLocalSystem = nil;

// my Bundle (not the main bundle!)
static NSBundle* defaultBundle = nil;
static NSBundle* currentBundle = nil;
static NSString* currentLang = nil;

@implementation JXLocalizeHelper

+ (JXLocalizeHelper*)sharedLocalSystem {
    // lazy instantiation
    if (SingleLocalSystem == nil) {
        SingleLocalSystem = [[JXLocalizeHelper alloc] init];
    }
    return SingleLocalSystem;
}

- (id)init {
    self = [super init];
    if (self) {
        defaultBundle =
                [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"JXUIResources"
                                                                         ofType:@"bundle"]];
    }
    return self;
}

//-------------------------------------------------------------
// translate a string
//-------------------------------------------------------------
- (NSString*)localizedStringForKey:(NSString*)key {
    if (currentBundle) {
        return [currentBundle localizedStringForKey:key value:@"" table:@"JXUIKit"];
    }
    return [defaultBundle localizedStringForKey:key value:@"" table:@"JXUIKit"];
}

//-------------------------------------------------------------
// set a new language
//-------------------------------------------------------------
// LocalizationSetLanguage(@"German") or LocalizationSetLanguage(@"de");
- (void)setLanguage:(NSString*)lang {
    // path to this languages bundle
    NSString* path = [defaultBundle pathForResource:lang ofType:@"lproj"];
    if (path == nil) {
        currentBundle = nil;
        currentLang = nil;
    } else {
        currentLang = lang;
        currentBundle = [NSBundle bundleWithPath:path];
    }
}

- (NSString *)getLanguage {
    return currentLang;
}

@end
