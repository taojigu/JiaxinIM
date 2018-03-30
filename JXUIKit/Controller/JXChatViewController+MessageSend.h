//
//  JXChatViewController+MessageSend.h
//

#import "JXChatViewController.h"

@interface JXChatViewController (MessageSend)

- (JXMessage *)sendMessageWithContentType:(JXMessageType)type
                              textContent:(NSString *)text
                                 filePath:(NSString *)filePath
                                    image:(UIImage *)image
                               videoThumb:(NSString *)videoThumb
                            audioDuration:(NSInteger)millisecond
                                 latitude:(double)latitude
                                longitude:(double)longitude;

- (void)insertTipsMessage:(NSString *)tips;

- (void)sendTextMessage:(NSString *)text;

- (void)sendLocationMessage:(NSString *)address
                   latitude:(double)latitude
                  longitude:(double)longitude;

- (void)sendImageMessage:(UIImage *)image;

- (void)sendImageMessageWithUrl:(NSString *)imageUrl;

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration;

- (void)sendRichMessageWithImage:(UIImage *)image
                           title:(NSString *)title
                         content:(NSString *)content
                             url:(NSString *)url;

- (void)sendRichmessageWithImageUrl:(NSString *)imageUrl
                              title:(NSString *)title
                            content:(NSString *)content
                                url:(NSString *)url;

- (void)sendVideoMessageWithLocalPah:(NSString *)localPath
                           thumbPath:(NSString *)videoThumb
                            duration:(NSInteger)duration;

- (void)sendForeseeMessage:(NSString *)title;

- (void)resendMessage:(JXMessage *)message;

@end
