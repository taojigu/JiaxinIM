//
//  JXChatViewController+Chatroom.m
//

#import "JXChatViewController+Chatroom.h"
#import <objc/runtime.h>

static const void *kUserCacheKey = &kUserCacheKey;
static const void *kChatroomKey = &kChatroomKey;
static const void *kUserCountKey = &kUserCountKey;

@implementation JXChatViewController (Chatroom)

- (JXChatroom *)chatroom {
    return objc_getAssociatedObject(self, kChatroomKey);
}

- (void)setChatroom:(JXChatroom *)chatroom {
    objc_setAssociatedObject(self, kChatroomKey, chatroom, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)userCount {
    NSNumber *count = objc_getAssociatedObject(self, kUserCountKey);
    return count.integerValue;
}

- (void)setUserCount:(NSInteger)count {
    if (count > self.chatroom.maxMembers) {
        // 聊天室人数已满owner进入人数不加1
        count = self.chatroom.maxMembers;
    }
    self.title = [NSString stringWithFormat:@"%@(%zd/%zd)", self.chatroom.subject, count,
                                            self.chatroom.maxMembers];
    NSNumber *num = [NSNumber numberWithInteger:count];
    objc_setAssociatedObject(self, kUserCountKey, num, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)chatroomUserDic {
    id userCache = objc_getAssociatedObject(self, kUserCacheKey);
    if (!userCache) {
        userCache = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, kUserCacheKey, userCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return userCache;
}

- (void)joinChatroom {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.conversation.type == JXChatTypeRoom) {
            [self showMessageWithActivityIndicator:JXUIString(@"loading")];
            [sClient.chatRoomManager joinChatroom:self.conversation.chatter];
        }
    });
}

- (void)leaveChatroom {
    if (self.conversation.type == JXChatTypeRoom) {
        [sClient.chatRoomManager leaveChatroom:self.conversation.chatter];
        [sClient.chatManager destoryConversation:self.conversation];
    }
}

#pragma mark - JXChatroomManagerDelegate

- (void)didLeaveChatroom:(NSString *)roomId {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatroomUserDic removeAllObjects];
    });
}

- (void)didJoinChatroom:(NSString *)roomId withError:(JXError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHUD];
        if (error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [self.navigationController popViewControllerAnimated:YES];
                           });
        } else {
            self.userCount++;
        }
    });
}

- (void)peopleJoinChatroom:(NSString *)useName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [sJXHUD showMessage:[NSString stringWithFormat:@"%@ join", useName] duration:1.6];
        NSString *user = [self.chatroomUserDic objectForKey:useName];
        if (!user) {
            if (self.userCount < self.chatroom.maxMembers) {
                self.userCount++;
            }
            [self.chatroomUserDic setObject:useName forKey:useName];
        }
    });
}

- (void)peopleLeaveChatroom:(NSString *)useName {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *textDisplay = [NSString stringWithFormat:@"%@ left", useName];
        sJXHUDMes(textDisplay, 1.6);
        NSString *user = [self.chatroomUserDic objectForKey:useName];
        if (user) {
            self.userCount--;
            [self.chatroomUserDic removeObjectForKey:useName];
        }
    });
}

- (void)chatroomDidDestory:(NSString *)roomId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *messasge = [NSString stringWithFormat:@"%@ destroied", self.chatroom.subject];
        [sJXHUD showMessage:messasge duration:1.0];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

@end
