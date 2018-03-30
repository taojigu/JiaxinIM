//
//  NSString+Extends.m
//

#import "NSString+Extends.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Extends)

- (NSString *)stringByReplaceHTMLTag:(NSString *)tag withString:(NSString *)replaced {
    NSError *error = nil;

    NSString *pattern = [NSString stringWithFormat:@"<%@[^>]+>", tag];
    NSRegularExpression *regex =
            [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, [self length])
                                      withTemplate:replaced];
}

- (NSString *)stringByReplacingPatternInString:(NSString *)patten
                                  withTemplate:(NSString *)replaced {
    NSError *error = nil;
    NSRegularExpression *regex =
            [NSRegularExpression regularExpressionWithPattern:patten
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, [self length])
                                      withTemplate:replaced];
}

- (NSString *)strippedContent {
    NSString *ret = [self stringByReplaceHTMLTag:@"img" withString:@""];
    ret = [ret stringByReplacingPatternInString:@"<[^>]+>" withTemplate:@""];
    NSMutableString *mutableRet = [NSMutableString stringWithString:ret];
    [mutableRet replaceOccurrencesOfString:@"\\r"
                                withString:@"\r"
                                   options:NSCaseInsensitiveSearch
                                     range:NSMakeRange(0, mutableRet.length)];
    [mutableRet replaceOccurrencesOfString:@"\\n"
                                withString:@"\n"
                                   options:NSCaseInsensitiveSearch
                                     range:NSMakeRange(0, mutableRet.length)];
    [mutableRet replaceOccurrencesOfString:@"\\t"
                                withString:@"\t"
                                   options:NSCaseInsensitiveSearch
                                     range:NSMakeRange(0, mutableRet.length)];
    ret = [mutableRet
           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [[NSAttributedString alloc]
                         initWithData:[ret dataUsingEncoding:NSUTF8StringEncoding]
                              options:@{
                                  NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                                  NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)
                              }
                   documentAttributes:nil
                                error:nil]
            .string;
}

+ (BOOL)isBlankString:(NSString *)string {
    return ![string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

+ (NSString *)convertFaceCodeToEmojiFace:(NSString *)origalstr {
    NSMutableArray *arrayCompair = [[NSMutableArray alloc] init];
    for (int i = 0x1F600; i <= 0x1F64F; i++) {
        if (i < 0x1F641 || i > 0x1F644) {
            [arrayCompair addObject:[NSString stringWithFormat:@"/u%1x", i]];
        }
    }
    NSString *strReturn = origalstr;
    for (int i = 0; i < [arrayCompair count]; i++) {
        NSRange range = [[origalstr lowercaseString]
                rangeOfString:[[arrayCompair objectAtIndex:i] lowercaseString]];
        if (range.location != NSNotFound) {
            NSString *strcccc = [origalstr substringWithRange:range];
            NSString *hex = [strcccc stringByReplacingOccurrencesOfString:@"/u" withString:@""];
            NSScanner *scan = [NSScanner scannerWithString:hex];
            uint32_t unicode = -1;

            [scan scanHexInt:&unicode];

            NSString *face = [NSString convertToFaceString:unicode];
            strReturn = [strReturn stringByReplacingOccurrencesOfString:strcccc withString:face];
        }
    }
    return strReturn;
}

+ (NSString *)convertToFaceString:(uint32_t)unicode {
    NSString *smiley = [[NSString alloc] initWithBytes:&unicode
                                                length:sizeof(unicode)
                                              encoding:NSUTF32LittleEndianStringEncoding];
    return smiley;
}

+ (NSString *)convertToCustomEmoticons:(NSString *)text {
    if (text.length <= 0) return nil;

    NSMutableString *retText = [[NSMutableString alloc] initWithString:text];

    return retText;
}

+ (NSString *)convertToSystemEmoji:(NSString *)text {
    if (![text isKindOfClass:[NSString class]]) {
        return @"";
    }

    if ([text length] == 0) {
        return @"";
    }
    NSMutableString *retText = [[NSMutableString alloc] initWithString:text];
        NSRange range;
        range.location = 0;
        range.length = retText.length;
    return retText;
}

- (BOOL)isPureInt {
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isPureFloat {
    NSScanner *scan = [NSScanner scannerWithString:self];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

- (NSString *)jxmd5String {
    const char *str = self.UTF8String;
    uint8_t buffer[16];
    
    CC_MD5(str, (CC_LONG)strlen(str), buffer);
    
    return [self stringFromBytes:buffer length:CC_MD5_DIGEST_LENGTH];
}


+ (NSString *)timeStringFromTimeInterval:(NSTimeInterval)timeInterval {
    int totalSeconds = (int)timeInterval;
    if (totalSeconds < 0) {
        return @"0";
    }

    if (timeInterval < 60 * 60) {
        int minute = totalSeconds / 60;
        int second = totalSeconds % 60;
        return [NSString stringWithFormat:@"%d:%.2d'", minute, second];
    } else {
        int hour = totalSeconds / (60 * 60);
        int minute = (totalSeconds / 60) % 60;
        int second = totalSeconds % 60;
        return [NSString stringWithFormat:@"%d:%d:%.2d'", hour, minute, second];
    }
    return @"0";
}

/**
 *  返回二进制 Bytes 流的字符串表示形式
 *
 *  @param bytes  二进制 Bytes 数组
 *  @param length 数组长度
 *
 *  @return 字符串表示形式
 */
- (NSString *)stringFromBytes:(uint8_t *)bytes length:(int)length {
    NSMutableString *strM = [NSMutableString string];
    
    for (int i = 0; i < length; i++) {
        [strM appendFormat:@"%02x", bytes[i]];
    }
    
    return [strM copy];
}

- (CGSize)stringSizeWithFontSize:(UIFont *)aFont displaySize:(CGSize)aSize {
    CGSize size = [self boundingRectWithSize:aSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName : aFont}
                                     context:nil].size;
    return size;
}

@end

@implementation NSAttributedString (Utilities)

- (CGSize)attributeStringSizeWithFontSize:(UIFont *)aFont displaySize:(CGSize)aSize {
    CGSize size = aSize;
    CGSize lastSize = [self boundingRectWithSize:size
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           context:nil]
                              .size;
    return lastSize;
}

@end
