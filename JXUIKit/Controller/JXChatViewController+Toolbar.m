//
//  JXChatViewController+Chatroom.m
//

#import "JXChatViewController+MessageSend.h"
#import "JXChatViewController+Toolbar.h"
#import "JXMessageToolbar.h"
#import "JXVideoConverter.h"
#import "JXVideoRecordViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

static const void *kVoiceRecorder = &kVoiceRecorder;

@implementation JXChatViewController (Toolbar)

#pragma mark - public

- (void)toolBarAddPhotoItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    [self.messageToolbar moreViewAddPhotoItemWithTitle:title andImage:image];
}

- (void)toolbarAddCameraItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    [self.messageToolbar moreViewAddCameraItemWithTitle:title andImage:image];
}

- (void)toolbarAddVideoItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    [self.messageToolbar moreViewAddVideoItemWithTitle:title andImage:image];
}

- (void)toolbarAddAudioCallItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    [self.messageToolbar moreViewAddAudioCallItemWithTitle:title andImage:image];
}

- (void)toolbarAddVideoCallItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    [self.messageToolbar moreViewAddVideoCallItemWithTitle:title andImage:image];
}

- (void)toolbarAddLocationItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    [self.messageToolbar moreViewAddLocationItemWithTitle:title andImage:image];
}

- (void)toolbarAddCustomItemWithTitle:(NSString *)title
                             andImage:(UIImage *)image
                            andAction:(void (^)(NSInteger index))action {
    [self.messageToolbar moreViewAddCustomItemWithTitle:title andImage:image andAction:action];
}

- (void)toolbarDeleteCustomItemWithTitle:(NSString *)title
                                andImage:(UIImage *)image
                               andAction:(void (^)(NSInteger index))action {
    [self.messageToolbar moreViewDeleteCustomItemWithTitle:title andImage:image andAction:action];
}

- (void)hideToolbar:(BOOL)hidden {
    [self.messageToolbar resignFirstResponder];
    self.messageToolbar.hidden = hidden;
}

#pragma mark - private

- (void)recordOverTime {
    // if finish before prepare done, it would not start recording
    self.voiceRecorder.isCancelled = YES;
    // convert format
    if ([self.delegate respondsToSelector:@selector(chatViewController:
                                                   didSelectRecordView:
                                                          withEvenType:)]) {
        [self.delegate chatViewController:self
                      didSelectRecordView:self.messageToolbar.recordView
                             withEvenType:JXRecordViewTypeTouchUpInside];
    } else {
        [(JXRecordView *)self.messageToolbar.recordView recordButtonTouchUpInside];
        [self.messageToolbar.recordView removeFromSuperview];
    }
    [self sendVoiceMessageWithLocalPath:self.voiceRecorder.recordPath
                                 duration:self.voiceRecorder.recordDuration];
}

- (JXVoiceMessageRecorder *)voiceRecorder {
    JXVoiceMessageRecorder *ret = objc_getAssociatedObject(self, kVoiceRecorder);
    if (!ret) {
        ret = [[JXVoiceMessageRecorder alloc] init];
        objc_setAssociatedObject(self, kVoiceRecorder, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        WEAKSELF;
        ret.maxTimeStopRecorderCompletion = ^{
            [weakSelf recordOverTime];
        };
    }
    return ret;
}

#pragma mark - JXMessageToolbarDelegate

- (void)didChangeFrameToHeight:(CGFloat)toHeight {
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rect = self.tableView.frame;
                         rect.origin.y = 0;
                         rect.size.height = self.view.frame.size.height - JXSafeAreaBottom - toHeight;
                         self.tableView.frame = rect;
                     }];
    
    [self.tableView scrollToBottomWithAnimation:YES];
}

- (void)inputTextViewWillBeginEditing:(JXMessageTextView *)inputTextView {
    // if (_menuController == nil) {
    //    _menuController = [UIMenuController sharedMenuController];
    //}
    //[_menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text {
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView {
    if ([self.delegate respondsToSelector:@selector(chatViewController:
                                                   didSelectRecordView:
                                                          withEvenType:)]) {
        [self.delegate chatViewController:self
                      didSelectRecordView:recordView
                             withEvenType:JXRecordViewTypeTouchDown];
    } else {
        [(JXRecordView *)self.messageToolbar.recordView recordButtonTouchDown];
    }

    if ([self.voiceRecorder canRecord]) {
        // 录音停止播放
        [sVoiceMessagePlayer stopPlayAudio];
        JXRecordView *tmpView = (JXRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d", (int)time, x];
        self.tableView.userInteractionEnabled = NO;

        WEAKSELF;
        self.voiceRecorder.isCancelled = NO;
        [self.voiceRecorder prepareWithFilePath:fileName
                                  andCompletion:^{
                                      if (weakSelf.voiceRecorder.isCancelled) return;
                                      [weakSelf.voiceRecorder startWithCompletion:^{
                                      }];
                                  }];
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView {
    if ([self.delegate respondsToSelector:@selector(chatViewController:
                                                   didSelectRecordView:
                                                          withEvenType:)]) {
        [self.delegate chatViewController:self
                      didSelectRecordView:recordView
                             withEvenType:JXRecordViewTypeTouchUpOutside];
    } else {
        [(JXRecordView *)self.messageToolbar.recordView recordButtonTouchUpOutside];
        [self.messageToolbar.recordView removeFromSuperview];
    }

    self.tableView.userInteractionEnabled = YES;
    self.voiceRecorder.isCancelled = YES;
    [self.voiceRecorder cancelCurrentRecord];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecordingVoiceAction:(UIView *)recordView {
    // if finish before prepare done, it would not start recording
    self.voiceRecorder.isCancelled = YES;
    // convert format
    if ([self.delegate respondsToSelector:@selector(chatViewController:
                                                   didSelectRecordView:
                                                          withEvenType:)]) {
        [self.delegate chatViewController:self
                      didSelectRecordView:recordView
                             withEvenType:JXRecordViewTypeTouchUpInside];
    } else {
        [(JXRecordView *)self.messageToolbar.recordView recordButtonTouchUpInside];
        [self.messageToolbar.recordView removeFromSuperview];
    }

    self.tableView.userInteractionEnabled = YES;
    WEAKSELF;
    [self.voiceRecorder stopWithCompletion:^(JXRecordErrorType type) {
        if (type == JXRecordErrorTypeRecordTimeToShort) {
        } else if (type == JXRecordErrorTypeNone) {
            [weakSelf sendVoiceMessageWithLocalPath:weakSelf.voiceRecorder.recordPath
                                           duration:weakSelf.voiceRecorder.recordDuration];
        }
    }];
}

- (void)didDragInsideAction:(UIView *)recordView {
    if ([self.delegate respondsToSelector:@selector(chatViewController:
                                                   didSelectRecordView:
                                                          withEvenType:)]) {
        [self.delegate chatViewController:self
                      didSelectRecordView:recordView
                             withEvenType:JXRecordViewTypeDragInside];
    } else {
        [(JXRecordView *)self.messageToolbar.recordView recordButtonDragInside];
    }
}

- (void)didDragOutsideAction:(UIView *)recordView {
    if ([self.delegate respondsToSelector:@selector(chatViewController:
                                                   didSelectRecordView:
                                                          withEvenType:)]) {
        [self.delegate chatViewController:self
                      didSelectRecordView:recordView
                             withEvenType:JXRecordViewTypeDragOutside];
    } else {
        [(JXRecordView *)self.messageToolbar.recordView recordButtonDragOutside];
    }
}

/**
 *  录音音量
 */
- (double)currentVolume {
    return self.voiceRecorder.currentVolume;
}

/**
 *  moreView选择发送图片
 */
- (void)didSelectedPhotoAction:(UIView *)moreView {
    if ([UIImagePickerController
                isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[NSArray alloc]
                initWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        [sJXHUD showMessage:JXUIString(@"app could not acess album") duration:1.6];
    }
}

/**
 *  moreView选择拍照
 */
- (void)didSelectedCameraAction:(UIView *)moreView {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        [sJXHUD showMessage:JXUIString(@"app could not acess camera") duration:1.6];
    }
}

/**
 *  moreView选择小视频
 */
- (void)didSelectedVideoAction:(UIView *)moreView {
    JXVideoRecordViewController *videoRecordVC = [[JXVideoRecordViewController alloc] init];
    [self presentViewController:videoRecordVC animated:YES completion:nil];
    [self.messageToolbar endEditing:YES];
    WEAKSELF;
    [videoRecordVC setCompleteAction:^(NSDictionary *info) {
        NSString *localPath = [(NSURL *)info[JXRecorderMovieURL] absoluteString];
        UIImage *image = info[JXRecorderFirstFrame];
        NSInteger duarion = [info[JXRecorderDuration] integerValue];
        NSString *thumbImagePath = [localPath stringByAppendingString:@"thumb.img"];
        if ([UIImagePNGRepresentation(image) writeToFile:thumbImagePath atomically:YES]) {
            [weakSelf sendVideoMessageWithLocalPah:localPath
                                         thumbPath:thumbImagePath
                                          duration:duarion];
        }
    }];
}

/**
 *  moreView选择视频通话
 */
- (void)didSelectedVideoCallAction:(UIView *)moreView {
}

/**
 *  moreView选择语音通话
 */
- (void)didSelectedAudioCallAction:(UIView *)moreView {
}

/**
 *  moreView选择发送位置
 */
- (void)didselectedLocationAction:(UIView *)moreView {
    JXLocationViewController *locationVC = [[JXLocationViewController alloc] init];
    WEAKSELF;
    locationVC.locationBlock = ^(NSString *locationStr, CLLocation *location) {
        [weakSelf sendLocationMessage:locationStr
                             latitude:location.coordinate.latitude
                            longitude:location.coordinate.longitude];
    };
    UINavigationController *nav =
            [[UINavigationController alloc] initWithRootViewController:locationVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL)toolBarAllowEmojiChat:(JXMessageToolbar *)toolbar {
    if (self.isAllowEmojiChat) {
        return YES;
    }
    return NO;
}

- (BOOL)toolBarAllowVoiceChat:(JXMessageToolbar *)toolbar {
    if (self.isAllowVoiceChat) {
        return YES;
    }
    return NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        // 设置文件名
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d", (int)time, x];
        NSString *recordPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        NSString *mp4FilePath =
                [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
        NSString *thunbFilePath = [recordPath stringByAppendingString:@"thumb.img"];
        // MOV转为MP4
        if ([JXVideoConverter convertMovToMP4:info[UIImagePickerControllerMediaURL]
                                        ToURL:[NSURL fileURLWithPath:mp4FilePath]]) {
            // 获取文件时长
            NSDictionary *opts =
                    [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *urlAsset =
                    [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:mp4FilePath] options:opts];
            float duration = urlAsset.duration.value / urlAsset.duration.timescale;
            // 判断视频是否过大
            if ([NSData dataWithContentsOfFile:mp4FilePath].length > 1024 * 1024 * 5) {
                [[NSFileManager defaultManager] removeItemAtPath:mp4FilePath error:nil];
                sJXHUDMes(@"file size is too big", 1.3);
                [picker dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            // 获取缩略图
            WEAKSELF;
            [[JXVideoConverter sharedInstance]
                    convertVideoFirstFrameWithURL:[NSURL fileURLWithPath:mp4FilePath]
                                      finishBlock:^(id image) {
                                          if ([UIImagePNGRepresentation([image fixOrientation])
                                                      writeToFile:thunbFilePath
                                                       atomically:YES]) {
                                              [weakSelf sendVideoMessageWithLocalPah:mp4FilePath
                                                                           thumbPath:thunbFilePath
                                                                            duration:duration];
                                          }
                                          [picker dismissViewControllerAnimated:YES completion:nil];
                                      }];
        }
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage *image = [info[UIImagePickerControllerOriginalImage] fixOrientation];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if ([picker.mediaTypes count] > 0) {
                [self sendImageMessage:image];
            }
        });
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
