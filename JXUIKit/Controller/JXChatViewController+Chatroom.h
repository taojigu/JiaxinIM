//
//  JXChatViewController+Chatroom.h
//

#import "JXChatViewController.h"

@interface JXChatViewController (Chatroom)

@property(nonatomic, strong) JXChatroom *chatroom;

- (void)joinChatroom;

- (void)leaveChatroom;

@end
