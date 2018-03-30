//
//  JXMessageFileDownloader.m
//

#import "JXMessageFileDownloader.h"
#import "JXSDKHelper.h"

@implementation JXDownloadStatus

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = kDownloadStatusUndownload;
        _progress = 0;
    }
    return self;
}

@end

@interface JXMessageFileDownloader ()
@property(atomic, strong) NSMutableArray *oberverList;
@property(atomic, strong) NSMutableSet *fileDownloadMessages;
@end

@implementation JXMessageFileDownloader

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)addDownloadStatusObserver:(id<JXMessageFileDownloaderDelegate>)observer {
    if (!observer) {
        return;
    }
    JXMessageFileDownloader *manager = [JXMessageFileDownloader sharedInstance];
    if (!manager.oberverList) {
        manager.oberverList = [NSMutableArray array];
    }
    [manager.oberverList addObject:observer];
}

+ (void)removeDownloadStatusObserver:(id<JXMessageFileDownloaderDelegate>)observer {
    JXMessageFileDownloader *manager = [JXMessageFileDownloader sharedInstance];
    if (!manager.oberverList) {
        return;
    }
    if (observer && [manager.oberverList containsObject:observer]) {
        [manager.oberverList removeObject:observer];
    }
}

+ (void)downloadFileForMessage:(JXMessage *)message {
    if (!message || [self isDownloadingMessage:message.messageId]) return;
    JXMessageFileDownloader *manager = [JXMessageFileDownloader sharedInstance];
    if (!manager.fileDownloadMessages) {
        manager.fileDownloadMessages = [NSMutableSet set];
    }
    JXDebugAssert(message.messageId);
    [manager.fileDownloadMessages addObject:message.messageId];

    NSString *messageID = [message.messageId copy];
    [sClient.chatManager downloadAttachmentForMessage:message
            result:^(id result, JXError *error) {
                if (error) {
                    [manager fileDownloadFailed:messageID];
                } else {
                    [manager fileDownloadFinished:messageID];
                }
            }
            progress:^(float progress) {
                [manager updateMessageFileDownloadProgress:progress withMessageID:messageID];
            }];
}

+ (BOOL)isDownloadingMessage:(NSString *)messageID {
    JXMessageFileDownloader *manager = [JXMessageFileDownloader sharedInstance];
    return [manager.fileDownloadMessages containsObject:messageID];
}

#pragma mark -
#pragma mark - private method

- (void)updateMessageFileDownloadProgress:(float)progress withMessageID:(NSString *)messageID {
    if (!messageID) return;
    for (id observer in self.oberverList) {
        if ([observer respondsToSelector:@selector(didMessage:updateProgress:)]) {
            [observer didMessage:messageID updateProgress:progress];
        }
    }
}

- (void)fileDownloadFailed:(NSString *)messageID {
    if (!messageID) return;
    for (id observer in self.oberverList) {
        if ([observer respondsToSelector:@selector(messageFileDownloadFailed:)]) {
            [observer messageFileDownloadFailed:messageID];

            for (NSString *downloadingMessageID in self.fileDownloadMessages) {
                if ([messageID isEqualToString:downloadingMessageID]) {
                    [self.fileDownloadMessages removeObject:downloadingMessageID];
                    break;
                }
            }
        }
    }
}

- (void)fileDownloadFinished:(NSString *)messageID {
    if (!messageID) return;
    for (id observer in self.oberverList) {
        if ([observer respondsToSelector:@selector(messageFileDownloadSuccesed:)]) {
            [observer messageFileDownloadSuccesed:messageID];
            for (NSString *downloadingMessageID in self.fileDownloadMessages) {
                if ([messageID isEqualToString:downloadingMessageID]) {
                    [self.fileDownloadMessages removeObject:downloadingMessageID];
                    break;
                }
            }
        }
    }
}

@end
