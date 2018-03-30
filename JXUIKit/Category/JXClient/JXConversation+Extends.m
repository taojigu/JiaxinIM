//
//  JXConversation+Extends.m
//

#import "JXConversation+Extends.h"
#import <objc/runtime.h>

#import "JXSDKHelper.h"

#define kAvatarImage @"kAvatarImage"
#define kTitlel @"kTitle"

@implementation JXConversation (Extends)

- (NSArray *)loadMessagesBefore:(JXMessage *)message count:(NSUInteger)count {
    if (!count) return @[];

    BOOL start = NO;
    if (!message.messageId.length) start = YES;

    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:count];
    
    for (NSString *mid in [[self.messageIds reverseObjectEnumerator] allObjects]) {
        if (start && count) {
            JXMessage *message = [self messageForId:mid];
            if (message) {
                [ret addObject:message];
            }
            count--;
        }
        if (!start && [mid isEqualToString:message.messageId]) {
            start = YES;
        }
    }
    return [[ret reverseObjectEnumerator] allObjects];
}

- (JXMessage *)secondLatestMessage {
    if (self.messageIds.count < 2) return nil;

    NSRange range = NSMakeRange(self.messageIds.count - 2, 2);
    NSString *secondLatest = [[self.messageIds subarrayWithRange:range] firstObject];
    return [self messageForId:secondLatest];
}

- (UIImage *)avatarImage {
    UIImage *image = objc_getAssociatedObject(self, kAvatarImage);
    if (image) {
        return image;
    } else {
        if (self.type == JXChatTypeGroup) {
            return JXChatImage(@"groupDefaultHeaderIcon");
        } else if (self.type == JXChatTypeChat) {
            return JXChatImage(@"icon");
        }
    }
    return image;
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    objc_setAssociatedObject(self, kAvatarImage, avatarImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)title {
    NSString *title = objc_getAssociatedObject(self, kTitlel);
    if (title) {
        return title;
    } else {
        return self.subject;
    }
}

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, kTitlel, title, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
