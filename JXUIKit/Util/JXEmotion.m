//
//  JXEmotion.m
//  JXUIKit
//
//  Created by 刘佳 on 2017/1/20.
//  Copyright © 2017年 DY. All rights reserved.
//

#import "JXEmotion.h"
#import "JXSDKHelper.h"

#define kEmotionTopMargin -3.0f

static NSMutableDictionary *_emotionsCache;

@implementation JXEmotionPackage

- (instancetype)initWithEmotions:(NSArray<JXEmotion *> *)emotions andType:(JXEmotionType)type {
    if (self = [super init]) {
        _emotions = emotions.copy;
        _type = type;
    }
    return self;
}

@end

@implementation JXEmotion

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (NSMutableAttributedString *)attributtedStringFromText:(NSString *)aInputText {
    NSString *urlPattern = @"\\\\::([a-z]+)([0-9]+)]";
    NSError *error = nil;
    NSRegularExpression *regex =
            [NSRegularExpression regularExpressionWithPattern:urlPattern
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];

    NSArray *matches = [regex matchesInString:aInputText
                                      options:NSMatchingReportCompletion
                                        range:NSMakeRange(0, [aInputText length])];
    NSMutableAttributedString *string =
            [[NSMutableAttributedString alloc] initWithString:aInputText attributes:nil];

    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSRange matchRange = [match range];
        //            if(NSTextCheckingTypeRegularExpression == [match resultType])
        //                NSLog(@"%@",[match grammarDetails]);
        NSString *subStr = [aInputText substringWithRange:matchRange];

        NSString *typePattern = @"([a-z]+)";
        NSString *namePattern = @"([0-9]+)";
        NSRegularExpression *typeRegex =
                [NSRegularExpression regularExpressionWithPattern:typePattern
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
        NSArray *typeMatches = [typeRegex matchesInString:subStr
                                                  options:NSMatchingReportCompletion
                                                    range:NSMakeRange(0, [subStr length])];
        NSString *type;
        for (NSTextCheckingResult *submatch in typeMatches) {
            type = [subStr substringWithRange:[submatch range]];
        }

        NSRegularExpression *nameRegex =
                [NSRegularExpression regularExpressionWithPattern:namePattern
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
        NSArray *nameMatches = [nameRegex matchesInString:subStr
                                                  options:NSMatchingReportCompletion
                                                    range:NSMakeRange(0, [subStr length])];
        NSString *number;
        for (NSTextCheckingResult *submatch in nameMatches) {
            number = [subStr substringWithRange:[submatch range]];
        }

        JXTextAttachment *textAttachment = [[JXTextAttachment alloc] initWithData:nil ofType:nil];
        textAttachment.imageName = number;
        UIImage *emojiImage;

        if ([type isEqualToString:@"a"]) {
            NSString *emojiName = [NSString stringWithFormat:@"a%@", number];
            emojiImage = [UIImage imageNamed:emojiName];
        }

        NSAttributedString *textAttachmentString;
        if (emojiImage) {
            textAttachment.image = emojiImage;
            textAttachmentString =
                    [NSAttributedString attributedStringWithAttachment:textAttachment];
        } else {
            NSString *str = [self getEmojiTextByKey:subStr];
            if (str != nil) {
                str = [NSString stringWithFormat:@"[%@]", str];
                textAttachmentString = [[NSAttributedString alloc] initWithString:str];
            } else {
                textAttachmentString =
                        [[NSAttributedString alloc] initWithString:JXUIString(@"emoji")];
            }
        }

        if (textAttachment != nil) {
            [string deleteCharactersInRange:matchRange];
            [string insertAttributedString:textAttachmentString atIndex:matchRange.location];
        }
    }

    //    [regex replaceMatchesInString:string.mutableString options:NSMatchingReportCompletion
    //    range:NSMakeRange(0, [string.mutableString length]) withTemplate:@""];
    return string;
}

+ (NSAttributedString *)attStringFromTextForChatting:(NSString *)aInputText {
    NSMutableAttributedString *string = [self attributtedStringFromText:aInputText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:0];
    [string addAttribute:NSParagraphStyleAttributeName
                   value:paragraphStyle
                   range:NSMakeRange(0, [string length])];
    return string;
}

+ (NSAttributedString *)attStringFromTextForInputView:(NSString *)aInputText {
    NSMutableAttributedString *string = [self attributtedStringFromText:aInputText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1.0;
    [string addAttribute:NSParagraphStyleAttributeName
                   value:paragraphStyle
                   range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:16.0f]
                   range:NSMakeRange(0, string.length)];
    return string;
}

+ (NSString *)getEmojiTextByKey:(NSString *)aKey {
    NSArray *paths =
            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPaht = [paths objectAtIndex:0];
    NSString *fileName = [plistPaht stringByAppendingPathComponent:@"EmotionTextMapList.plist"];
    NSMutableDictionary *emojiKeyValue =
            [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
    return [emojiKeyValue objectForKey:aKey];
    //    NSLog(@"write data is :%@",writeData);
}

+ (NSMutableString *)mutableStringWithText:(NSString *)str {
    NSArray *arrEmoji = [self loadAllExpressions];
    //正则匹配要替换的文字的范围
    NSString *pattern = @"\[\\[\u4e00-\u9fa5A-Za-z]{2,4}\\]";
    NSError *error = nil;
    NSRegularExpression *re =
            [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];

    //通过正则表达式来匹配字符串
    NSArray *resultArray = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *textArray = [NSMutableArray arrayWithCapacity:resultArray.count];

    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:str];
    for (NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];

        //获取原字符串中对应的值
        NSString *subStr = [str substringWithRange:range];
        NSRange chatRange = [subStr rangeOfString:@"["];
        if (chatRange.location != 0) {
            subStr = [subStr substringFromIndex:chatRange.location];
            range = NSMakeRange(range.location + chatRange.location,
                                range.length - chatRange.location);
        }

        for (JXEmotion *emotion in arrEmoji) {
            if ([emotion.chs isEqualToString:subStr]) {
                NSString *string = emotion.reg;
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *textDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [textDic setObject:string forKey:@"reg"];
                [textDic setObject:[NSValue valueWithRange:range] forKey:@"range"];

                //把字典存入数组中
                [textArray addObject:textDic];
            }
        }
    }

    //从后往前替换
    for (NSInteger i = textArray.count - 1; i >= 0; i--) {
        NSRange range;
        [textArray[i][@"range"] getValue:&range];
        //进行替换
        [mutableStr replaceCharactersInRange:range withString:textArray[i][@"reg"]];
    }

    return mutableStr;
}

+ (NSArray *)loadAllExpressions {
    NSMutableArray *allEmotions = [NSMutableArray array];
    for (NSArray *emotions in _emotionsCache.allValues) {
        [allEmotions addObjectsFromArray:emotions];
    }
    return allEmotions;
}

+ (NSArray *)emotionsWithPlistPath:(NSString *)path {
    if (!path.length) {
        return nil;
    }
    if (!_emotionsCache) {
        _emotionsCache = [NSMutableDictionary dictionary];
    }

    NSArray *emotions = _emotionsCache[path];
    if (emotions == nil) {
        NSArray *array = [NSArray arrayWithContentsOfURL:[NSURL fileURLWithPath:path]];

        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [arrayM addObject:[[self alloc] initWithDict:obj]];
        }];
        emotions = [arrayM copy];
        [_emotionsCache setObject:emotions forKey:path];
    }
    return emotions;
}

+ (NSAttributedString *)attributedEmojiStringWithText:(NSString *)str {
    NSMutableAttributedString *attributedString =
            [[NSMutableAttributedString alloc] initWithString:str];
    NSArray *arrEmoji = [self loadAllExpressions];
    //正则匹配要替换的文字的范围
    //正则表达式
    static NSString *pattern =
            @"/::\\)|/::~|/::B|/::\\||/:8-\\)|/::<|/::\\$|/::X|/::Z|/::'\\(|/::-\\||/"
            @"::@|/::P|/::D|/::O|/::\\(|/::\\+|/:--b|/::Q|/::T|/:,@P|/:,@-D|/::d|/"
            @":,@o|/::g|/:\\|-\\)|/::!|/::L|/::>|/::,@|/:,@f|/::-S|/:\\?|/:,@x|/:,@@|/"
            @"::8|/:,@!|/:!!!|/:xx|/:bye|/:wipe|/:dig|/:handclap|/:&-\\(|/:B-\\)|/"
            @":<@|/:@>|/::-O|/:>-\\||/:P-\\(|/::'\\||/:X-\\)|/::\\*|/:@x|/:8\\*|/:pd|/"
            @":<W>|/:beer|/:basketb|/:oo|/:coffee|/:eat|/:pig|/:rose|/:fade|/"
            @":showlove|/:heart|/:break|/:cake|/:li|/:bome|/:kn|/:footb|/:ladybug|/"
            @":shit|/:moon|/:sun|/:gift|/:hug|/:strong|/:weak|/:share|/:v|/:@\\)|/"
            @":jj|/:@@|/:bad|/:lvu|/:no|/:ok|/:love|/:<L>|/:jump|/:shake|/:<O>|/"
            @":circle|/:kotow|/:turn|/:skip|/:oY|/:#-0|/:hiphot|/:kiss|/:<&|/:&>|"
            @"\\[[a-zA-Z0-9;:<@#\\{\\}\\*\\'\\|\\+\\^\\-\\$\\(\\)\\u4e00-\\u9fa5]+\\]";

    NSError *error = nil;
    NSRegularExpression *re =
            [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];

    //通过正则表达式来匹配字符串
    NSArray *resultArray = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];

    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];

    for (NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];

        //获取原字符串中对应的值
        NSString *subStr = [str substringWithRange:range];

        for (JXEmotion *emotion in arrEmoji) {
            if ([emotion.reg isEqualToString:subStr]) {
                //新建文字附件来存放我们的图片
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //                    CGFloat n = 25/12;
                textAttachment.bounds = CGRectMake(textAttachment.bounds.origin.x,
                                                   textAttachment.bounds.origin.y - 5, 20, 20);

                //给附件添加图片
                textAttachment.image = JXChatImage(emotion.png);

                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr =
                        [NSAttributedString attributedStringWithAttachment:textAttachment];

                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];

                //把字典存入数组中
                [imageArray addObject:imageDic];
            }
        }
    }

    //从后往前替换
    for (NSInteger i = imageArray.count - 1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributedString replaceCharactersInRange:range
                              withAttributedString:imageArray[i][@"image"]];
    }
    [attributedString addAttributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:17.f]
    }
                              range:NSMakeRange(0, attributedString.length)];

    [imageArray removeAllObjects];
    return resultArray.count ? attributedString : nil;
}

@end

@implementation JXTextAttachment
// I want my emoticon has the same size with line's height
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0) {
    return CGRectMake(0, kEmotionTopMargin, lineFrag.size.height, lineFrag.size.height);
}

@end
