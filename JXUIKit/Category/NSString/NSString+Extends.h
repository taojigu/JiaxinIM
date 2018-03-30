//
//  NSString+Extends.h
//

#import <UIKit/UIKit.h>

@interface NSString (Extends)

+ (BOOL)isBlankString:(NSString *)string;

- (NSString *)stringByReplacingPatternInString:(NSString *)patten
                                  withTemplate:(NSString *)replaced;

- (NSString *)stringByReplaceHTMLTag:(NSString *)tag withString:(NSString *)replaced;

- (NSString *)strippedContent;

+ (NSString *)convertFaceCodeToEmojiFace:(NSString *)origalstr;

+ (NSString *)timeStringFromTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)convertToCustomEmoticons:(NSString *)text;

+ (NSString *)convertToSystemEmoji:(NSString *)text;

- (BOOL)isPureInt;

- (BOOL)isPureFloat;

- (NSString *)jxmd5String;

- (CGSize)stringSizeWithFontSize:(UIFont *)aFont displaySize:(CGSize)aSize;

@end

@interface NSAttributedString (Utilities)

- (CGSize)attributeStringSizeWithFontSize:(UIFont *)aFont displaySize:(CGSize)aSize;

@end
