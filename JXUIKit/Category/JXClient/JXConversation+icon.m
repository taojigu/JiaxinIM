//
//  JXConversation+icon.m
//

#import "JXConversation+icon.h"

@implementation JXConversation (icon)

- (NSString *)randomIcon {
    int hash = (int)[self.subject hash];
    int result = (abs(hash >> 5) % 3);
    NSString *iconStr = nil;
    switch (result) {
        case 0:
            iconStr = @"contactDefaultIcon";
            break;
        case 1:
            iconStr = @"contactDefaultIcon1";
            break;
        case 2:
            iconStr = @"contactDefaultIcon2";
            break;
    }
    return iconStr;
}

@end
