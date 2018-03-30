//
//  JXMessage+Extends.m
//

#import "JXMessage+Extends.h"
#import <objc/runtime.h>

#import "JXSDKHelper.h"

#import "JXEmotion.h"
#import "NSString+Extends.h"

static void *kText = &kText;
static void *kwechatText = &kwechatText;
static void *kAvatarImage = &kAvatarImage;
static void *kNickname = &kNickname;
static void *kCellHeight = &kCellHeight;
static void *kCellWidth = &kCellWidth;
static void *kIndexInTableView = &kIndexInTableView;
static void *kProgress = &kProgress;
static void *kFailedName = &kFailedName;
static void *kIsMediaPlaying = &kIsMediaPlaying;
static void *kAttributedText = &kAttributedText;
static void *kURLMatches = &kURLMatches;
static void *kHasHTMLTag = &kHasHTMLTag;

@implementation JXMessage (Extends)

- (UIImage *)avatarImage {
    UIImage *image = objc_getAssociatedObject(self, kAvatarImage);
    if (!image) {
        image = JXChatImage(@"icon");
    }
    return image;
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    objc_setAssociatedObject(self, kAvatarImage, avatarImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)failedImageName {
    NSString *name = objc_getAssociatedObject(self, kFailedName);
    if (!name) {
        name = @"ms_failed";
    }
    return name;
}

- (void)setFailedImageName:(NSString *)failedImageName {
    objc_setAssociatedObject(self, kFailedName, failedImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)nickname {
    return objc_getAssociatedObject(self, kNickname);
}

- (void)setNickname:(NSString *)nickname {
    objc_setAssociatedObject(self, kNickname, nickname, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellHeight {
    NSNumber *height = objc_getAssociatedObject(self, kCellHeight);
    return height ? height.doubleValue : -1;
}

- (void)setCellHeight:(CGFloat)cellHeight {
    NSNumber *height = [NSNumber numberWithDouble:cellHeight];
    objc_setAssociatedObject(self, kCellHeight, height, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellWidth {
    NSNumber *width = objc_getAssociatedObject(self, kCellWidth);
    return width ? width.doubleValue : -1;
}

- (void)setCellWidth:(CGFloat)cellWidth {
    NSNumber *width = [NSNumber numberWithDouble:cellWidth];
    objc_setAssociatedObject(self, kCellWidth, width, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kAttributedText, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)indexInTableView {
    NSNumber *index = objc_getAssociatedObject(self, kIndexInTableView);
    return index ? index.integerValue : -1;
}

- (void)setIndexInTableView:(NSInteger)indexInTableView {
    objc_setAssociatedObject(self, kIndexInTableView, [NSNumber numberWithInteger:indexInTableView],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)progress {
    NSNumber *n = objc_getAssociatedObject(self, kProgress);
    return n ? n.floatValue : 0;
}

- (void)setProgress:(float)progress {
    objc_setAssociatedObject(self, kProgress, [NSNumber numberWithFloat:progress],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isMediaPlaying {
    NSNumber *playing = objc_getAssociatedObject(self, kIsMediaPlaying);
    return playing.boolValue;
}

- (void)setIsMediaPlaying:(BOOL)isMediaPlaying {
    objc_setAssociatedObject(self, kIsMediaPlaying, [NSNumber numberWithBool:isMediaPlaying],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSender {
    return self.direction == JXMessageDirectionSend;
}

- (NSString *)textWithEmoji {
    NSString *ret;
    if ((ret = objc_getAssociatedObject(self, kText))) {
        return ret;
    }
    ret = [NSString convertToSystemEmoji:self.textToDisplay];
    objc_setAssociatedObject(self, kText, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return ret;
}

- (NSAttributedString *)textWithWechatEmoji:(NSString *)text {
    NSAttributedString *ret;
    if ((ret = objc_getAssociatedObject(self, kwechatText))) {
        return ret;
    }
    ret = [JXEmotion attributedEmojiStringWithText:text];
    if (!ret) {
        ret = [[NSAttributedString alloc] initWithString:@""];
    }
    objc_setAssociatedObject(self, kwechatText, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return ret;
}

- (UIImage *)defaultImage {
    return JXChatImage(@"PhotoDefaultIcon");
}

- (CGSize)thumbnailImageSize {
    CGSize ret = CGSizeMake(0, 0);
    if (self.type == JXMessageTypeImage || self.type == JXMessageTypeVideo) {
        UIImage *img = [UIImage imageWithContentsOfFile:self.thumbUrlToDisplay];
        if (!img) {
            img = [self defaultImage];
        }
        ret = img.size;
    }
    return ret;
}

- (NSString *)fileSizeDes {
    if (self.fileSize > 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2fM", (float)self.fileSize / (1024 * 1024)];
    } else if (self.fileSize > 1024) {
        return [NSString stringWithFormat:@"%.2fK", (float)self.fileSize / 1024];
    } else {
        return [NSString stringWithFormat:@"%.2fB", (float)self.fileSize];
    }
}

- (NSString *)durationDes {
    if (self.type == JXMessageTypeVideo) {
        NSInteger m = self.duration / 60;
        NSInteger s = self.duration % 60;
        return [NSString stringWithFormat:@"%02zd:%02zd", m, s];
    } else if (self.type == JXMessageTypeAudio) {
        NSInteger s = (int)self.duration;
        if (!s) {
            s = 1;
        }
        NSMutableString *res = [NSMutableString string];
        for (NSInteger i = s; i > 1; --i) {
            if (i > 20) i = 20;
            [res appendString:@"  "];
        }
        if (self.isSender) {
            return [NSString stringWithFormat:@"%@%zd''", res, s];
        } else {
            return [NSString stringWithFormat:@"%zd''%@", s, res];
        }
    }
    return nil;
}

- (NSMutableAttributedString *)attributedText {
    NSMutableAttributedString *ret;
    if ((ret = objc_getAssociatedObject(self, kAttributedText))) {
        return ret;
    }
    NSString *textToDisplay = self.textToDisplay;

    if ([self hasHTMLTag]) {
        if (self.cellWidth > 0) {
            textToDisplay = [self fixImgSizeInHTML:self.cellWidth];
        }
        ret = [[NSMutableAttributedString alloc]
                      initWithData:[textToDisplay dataUsingEncoding:NSUnicodeStringEncoding]
                           options:@{
                               NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType
                           }
                documentAttributes:nil
                             error:nil];
    } else if (self.type == JXMessageTypeText && [self urlMatches].count) {
        ret = [[NSMutableAttributedString alloc] initWithString:textToDisplay];
        for (NSTextCheckingResult *match in [self urlMatches]) {
            if ([match resultType] == NSTextCheckingTypeLink ||
                [match resultType] == NSTextCheckingTypeReplacement ||
                [match resultType] == NSTextCheckingTypePhoneNumber) {
                NSRange matchRange = [match range];
                [ret addAttribute:NSUnderlineStyleAttributeName
                               value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                               range:matchRange];
            }
        }
    } else if (self.type == JXMessageTypeText &&
               [self textWithWechatEmoji:textToDisplay].string.length) {
        ret = [[self textWithWechatEmoji:textToDisplay] mutableCopy];
    }
    if (ret) {
        objc_setAssociatedObject(self, kAttributedText, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return ret;
}

#pragma mark - url parsing

- (NSString *)fixImgSizeInHTML:(NSInteger)width {
    NSString *imgWidth = [NSString stringWithFormat:@"<img style=\"max-width:%ld;\"", (long)width];
    NSString *tmp = [self.textToDisplay stringByReplacingPatternInString:@"<p>" withTemplate:@""];
    tmp = [tmp stringByReplacingPatternInString:@"</p>" withTemplate:@"<br/>"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<img " withString:imgWidth];
    return [tmp stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
}

- (BOOL)hasHTMLTag {
    if (self.type != JXMessageTypeText) {
        return NO;
    }
    NSString *text = self.textToDisplay;
    if (!text.length) {
        return NO;
    }
    NSNumber *ret;
    if ((ret = objc_getAssociatedObject(self, kHasHTMLTag))) {
        return [ret boolValue];
    }

    NSRegularExpression *regex =
            [NSRegularExpression regularExpressionWithPattern:@"<(img|br|p)[^>]+>|</?p>"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:text
                                                    options:NSMatchingReportCompletion
                                                      range:NSMakeRange(0, text.length)];
    ret = [NSNumber numberWithBool:match ? YES : NO];
    objc_setAssociatedObject(self, kHasHTMLTag, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [ret boolValue];
}

- (NSArray<NSTextCheckingResult *> *)urlMatches {
    NSArray *ret;
    if ((ret = objc_getAssociatedObject(self, kURLMatches))) {
        return ret;
    }

    NSDataDetector *detector = [NSDataDetector
            dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber
                            error:nil];
    NSString *text =
            [self.textToDisplay stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
    ret = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    if (!ret) ret = [NSArray array];
    objc_setAssociatedObject(self, kURLMatches, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return ret;
}

@end
