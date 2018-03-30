//
//  JXChatViewController+MessageSend.m
//

#import "JXChatViewController+MessageSend.h"

#import "JXSDKHelper.h"
#import "NSString+Extends.h"

@implementation JXChatViewController (MessageSend)

- (JXMessage *)sendMessageWithContentType:(JXMessageType)type
                              textContent:(NSString *)text
                                 filePath:(NSString *)filePath
                                    image:(UIImage *)image
                               videoThumb:(NSString *)videoThumb
                            audioDuration:(NSInteger)millisecond
                                 latitude:(double)latitude
                                longitude:(double)longitude {
    if (JXMessageTypeText == type) {
        if ([text length] <= 0) {
            NSAssert(text, @"message text can not be empty!");
            return nil;
        }
    } else if (JXMessageTypeLocation == type) {
    } else if (JXMessageTypeForeseeComposing == type) {
    } else if (JXMessageTypeForeseeRecording == type) {
    } else if (JXMessageTypeImage == type) {
        if (!image) {
            NSAssert(image, @"image can not be nil");
            return nil;
        }
    } else if (!filePath) {
        NSAssert(filePath, @"filePath can not be nil");
        return nil;
    }
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    switch (type) {
        case JXMessageTypeText: {
            //            [message setTextContent:[NSString convertToCustomEmoticons:text]];
            [message setTextContent:text];
        } break;
        case JXMessageTypeImage: {
            [message setImageContent:UIImagePNGRepresentation(image) compressionRate:1.0];
        } break;
        case JXMessageTypeAudio: {
            [message setAudioContent:filePath duration:millisecond];
        } break;
        case JXMessageTypeVideo: {
            [message setVideoContent:filePath thumbPath:videoThumb duration:millisecond];
        } break;
        case JXMessageTypeFile: {
            [message setFileContent:UIImagePNGRepresentation(image)];
        } break;
        case JXMessageTypeVcard: {
            // TODO:发送名片
            JXDebugAssert(NO);
        } break;
        case JXMessageTypeLocation: {
            [message setLocContent:text latitude:latitude longitude:longitude];
        } break;
        case JXMessageTypeForeseeComposing: {
            [message setForeseeContent:[NSString convertToCustomEmoticons:text]
                               andType:JXMessageTypeForeseeComposing];
        } break;
        case JXMessageTypeForeseeRecording: {
            [message setForeseeContent:nil andType:JXMessageTypeForeseeRecording];
        } break;
        default:
            break;
    }

    [sClient.chatManager sendMessage:message];
    return message;
}

- (void)insertTipsMessage:(NSString *)tips {
    JXMessage *message = [[JXMessage alloc] initWithReceiver:self.conversation.chatter
                                                     andType:self.conversation.type];
    [message setTipsContent:tips];
    [sClient.chatManager addMessage:message];
}

- (void)sendTextMessage:(NSString *)text {
    if (!text.length) return;

    [self sendMessageWithContentType:JXMessageTypeText
                           textContent:text
                              filePath:nil
                                 image:nil
                            videoThumb:nil
                         audioDuration:0
                              latitude:0
                             longitude:0];
}

- (void)sendLocationMessage:(NSString *)address
                   latitude:(double)latitude
                  longitude:(double)longitude {
    if (!address.length) {
        return;
    }
    [self sendMessageWithContentType:JXMessageTypeLocation
                           textContent:address
                              filePath:nil
                                 image:nil
                            videoThumb:nil
                         audioDuration:0
                              latitude:latitude
                             longitude:longitude];
}

- (void)sendImageMessage:(UIImage *)image {
    if (!image) {
        return;
    }
    [self sendMessageWithContentType:JXMessageTypeImage
                           textContent:nil
                              filePath:nil
                                 image:image
                            videoThumb:nil
                         audioDuration:0
                              latitude:0
                             longitude:0];
}

- (void)sendImageMessageWithUrl:(NSString *)imageUrl {
    if (!imageUrl.length) {
        return;
    }
    
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    [message setImageUrl:imageUrl];
    [sClient.chatManager sendMessage:message];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath duration:(NSInteger)duration {
    if (!localPath.length || !duration) {
        return;
    }
    [self sendMessageWithContentType:JXMessageTypeAudio
                           textContent:nil
                              filePath:localPath
                                 image:nil
                            videoThumb:nil
                         audioDuration:duration
                              latitude:0
                             longitude:0];
}

- (void)sendRichMessageWithImage:(UIImage *)image
                           title:(NSString *)title
                         content:(NSString *)content
                             url:(NSString *)url {
    if (!image || !title.length) {
        return;
    }
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    [message setRichTextContent:content
                          title:title
                        linkURL:url
                          image:UIImagePNGRepresentation(image)];
    [sClient.chatManager sendMessage:message];
}

- (void)sendRichmessageWithImageUrl:(NSString *)imageUrl
                              title:(NSString *)title
                            content:(NSString *)content
                                url:(NSString *)url {
    if (!imageUrl.length || !title.length) {
        return;
    }
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    [message setRichTextContent:content
                          title:title
                        linkURL:url
                       imageURL:imageUrl];
    [sClient.chatManager sendMessage:message];
}

- (void)sendVideoMessageWithLocalPah:(NSString *)localPath
                           thumbPath:(NSString *)videoThumb
                            duration:(NSInteger)duration {
    if (!localPath.length || !videoThumb.length) {
        return;
    }
    [self sendMessageWithContentType:JXMessageTypeVideo
                           textContent:nil
                              filePath:localPath
                                 image:nil
                            videoThumb:videoThumb
                         audioDuration:duration
                              latitude:0
                             longitude:0];
}

- (void)sendPicTextMessageWithText:(NSString *)title
                           content:(NSString *)content
                            picUrl:(NSString *)picUrl
                           linkUrl:(NSString *)linkUrl
                              date:(NSString *)date {
    JXMessage *message = [[JXMessage alloc] initWithConversation:self.conversation];
    [message setPicTextContent:content title:title picUrl:picUrl linkUrl:linkUrl date:date];
    [sClient.chatManager sendMessage:message];
}

- (void)sendForeseeMessage:(NSString *)title {
    [self sendMessageWithContentType:JXMessageTypeForeseeComposing
                           textContent:title
                              filePath:nil
                                 image:nil
                            videoThumb:nil
                         audioDuration:0
                              latitude:0
                             longitude:0];
}

- (void)resendMessage:(JXMessage *)message {
    if (!message) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong JXMessage *msg = message;
        [self.conversation deleteMessage:msg];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sClient.chatManager sendMessage:msg];
        });
    });
}

@end
