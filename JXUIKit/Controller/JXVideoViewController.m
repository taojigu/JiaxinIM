//
//  JXVideoViewController.m
//  JXUIKit
//
//  Created by raymond on 16/11/7.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "JXHUD.h"
#import "JXMessage.h"
#import "JXMessageFileDownloader.h"
#import "JXSDPieLoopProgressView.h"
#import "JXVideoViewController.h"
#import "UIImage+Extensions.h"

@interface JXVideoViewController ()<JXMessageFileDownloaderDelegate>

@property(nonatomic, strong) JXMessage *message;
@property(nonatomic, strong) JXSDPieLoopProgressView *progressView;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) AVPlayer *player;

@end

@implementation JXVideoViewController

- (instancetype)initWithMessage:(JXMessage *)message {
    if (self = [super init]) {
        _message = message;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [JXMessageFileDownloader addDownloadStatusObserver:self];

    NSData *video = [NSData dataWithContentsOfFile:self.message.localURL];
    self.imageView.jx_width = self.view.jx_width;
    self.imageView.jx_height = self.view.jx_height * (6.f / 9);
    self.imageView.jx_left = 0;
    self.imageView.jx_top = (self.view.jx_height - self.imageView.jx_height) * 0.5;
    [self.view addSubview:self.imageView];

    if (video.length != self.message.fileSize) {
        [[NSFileManager defaultManager] removeItemAtPath:self.message.localURL error:nil];
        _progressView = [[JXSDPieLoopProgressView alloc] initWithFrame:self.view.frame];
        _progressView.jx_width = 100;
        _progressView.jx_height = 100;
        _progressView.center = self.view.center;
        if (![JXMessageFileDownloader isDownloadingMessage:self.message.messageId]) {
            [JXMessageFileDownloader downloadFileForMessage:self.message];
        }
        [self.view addSubview:_progressView];
    } else {
        [self setupPlayerWith:self.message.localURL];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //    UITouch *touch = touches.anyObject;
    //    if (CGRectContainsPoint(self.imageView.frame, [touch locationInView:self.view])) {
    //        if ([self isPlaying]) {
    //            [self.player pause];
    //        } else {
    //            [self.player play];
    //        }
    //        return;
    //    }
    [self popSelf];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
    [JXMessageFileDownloader removeDownloadStatusObserver:self];
}

- (void)setupPlayerWith:(NSString *)urlString {
    self.imageView.hidden = YES;

    // 1.获取URL(远程/本地)
    NSURL *url = [NSURL fileURLWithPath:urlString];

    // 2.创建AVPlayerItem
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];

    // 3.创建AVPlayer
    self.player = [AVPlayer playerWithPlayerItem:item];
    if (IOSVersion >= 10.0) {
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }

    // 4.添加AVPlayerLayer
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.imageView.frame;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.view.layer addSublayer:layer];
    [self.player play];
}

- (BOOL)isPlaying {
    if (!self.player) return NO;
    if (IOSVersion >= 10.0) {
        return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    } else {
        return self.player.rate == 1;
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]
                initWithImage:[UIImage imageWithContentsOfFile:self.message.thumbUrlToDisplay]];
        [_imageView sizeToFit];
    }
    return _imageView;
}

#pragma mark - JXMessageFileDownloaderDelegate

- (void)messageFileDownloadSuccesed:(NSString *)messageID {
    if (messageID != self.message.messageId) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView dismiss];
        [self setupPlayerWith:_message.localURL];
    });
}

- (void)messageFileDownloadFailed:(NSString *)messageID {
    if (messageID != self.message.messageId) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        sJXHUDMes(JXUIString(@"fail to download"), 1.5);
        [self popSelf];
    });
}

- (void)didMessage:(NSString *)messageID updateProgress:(float)progress {
    if (messageID != self.message.messageId) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.progress = progress;
    });
}

@end
