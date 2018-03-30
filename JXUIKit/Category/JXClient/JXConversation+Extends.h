//
//  JXConversation+Extends.h
//

#import "JXConversation.h"

@interface JXConversation (Extends)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *avatarImage;

- (JXMessage *)secondLatestMessage;

- (NSArray *)loadMessagesBefore:(JXMessage *)message count:(NSUInteger)count;

@end
