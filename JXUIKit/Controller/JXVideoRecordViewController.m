//
//  JXVideoRecordViewController.m
//  JXUIKit
//
//  Created by raymond on 16/11/11.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXVideoRecordViewController.h"
#import "JXSDKHelper.h"
#import "JXVideoShootButton.h"

@interface JXVideoRecordViewController ()

// view
@property(strong, nonatomic) UIView *preview;
@property(strong, nonatomic) UIImageView *focusImageView;
@property(strong, nonatomic) UILabel *statusLabel;
@property(strong, nonatomic) JXVideoShootButton *longPressButton;
// indicator
@property(nonatomic, strong) CALayer *processLayer;

@property(nonatomic, assign, getter=isScale) BOOL scale;

@property(nonatomic, strong) JXMovieRecorder *recorder;

@end

@implementation JXVideoRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self prepareUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    if (IOSVersion >= 8.0) {
    [self setupRecorder];
    [_recorder startSession];
    //    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.recorder finishCapture];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    if (IOSVersion < 8.0) {
    //        [self setupRecorder];
    //        [_recorder startSession];
    //    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareUI {
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.preview];
    [self.preview addSubview:self.focusImageView];
    [self.view addSubview:self.longPressButton];
    [self.preview addSubview:self.statusLabel];
    NSDictionary *views = @{
        @"pv" : self.preview,
        @"fiv" : self.focusImageView,
        @"lpb" : self.longPressButton,
        @"sl" : self.statusLabel
    };
    [self.view addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-0-[pv]-0-[lpb(100)]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[pv]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lpb]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.preview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusImageView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.preview
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusImageView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:80]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusImageView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:80]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.preview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.preview
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:-25]];
}

- (void)setupRecorder {
    _recorder = [[JXMovieRecorder alloc] initWithMaxDuration:15.f];

    CGFloat width = 320.f;
    CGFloat Height = width / 4 * 3;
    _recorder.cropSize = CGSizeMake(width, Height);
    WEAKSELF;
    [_recorder setAuthorizationResultBlock:^(BOOL success) {
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sJXHUD showMessage:JXUIString(@"app could not access camera") duration:1.6];
                [weakSelf popSelf];
            });
        }
    }];

    [_recorder prepareCaptureWithBlock:^{
        // 1.video preview
        AVCaptureVideoPreviewLayer *preview = [_recorder getPreviewLayer];
        preview.backgroundColor = [UIColor blackColor].CGColor;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [preview removeFromSuperlayer];
        preview.frame = self.preview.frame;
        [weakSelf.preview.layer addSublayer:preview];

        // 2.doubleTap
        UITapGestureRecognizer *tapGR =
                [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(tapGR:)];
        tapGR.numberOfTapsRequired = 2;

        [weakSelf.preview addGestureRecognizer:tapGR];
    }];

    [_recorder setFinishBlock:^(NSDictionary *info, JXRecorderFinishedReason reason) {
        switch (reason) {
            case JXRecorderFinishedReasonNormal:
            case JXRecorderFinishedReasonBeyondMaxDuration: {    //正常结束
                if (weakSelf.completeAction) {
                    weakSelf.completeAction(info);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   [weakSelf popSelf];
                               });
                break;
            }
            case JXRecorderFinishedReasonCancle: {    //重置
                if ([[NSFileManager defaultManager]
                            fileExistsAtPath:[(NSURL *)info[JXRecorderMovieURL] absoluteString]]) {
                    if ([[NSFileManager defaultManager] removeItemAtURL:info[JXRecorderMovieURL]
                                                                  error:nil]) {
                    };
                };
                break;
            }
            default:
                break;
        }
    }];

    [_recorder setFocusAreaDidChangedBlock:^{
            //焦点改变

    }];

    [_longPressButton setStateChangeBlock:^(WKState state) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        switch (state) {
            case WKStateBegin: {
                [strongSelf.recorder startCapture];
                [strongSelf.statusLabel.superview bringSubviewToFront:strongSelf.statusLabel];
                [strongSelf showStatusLabelWithBackgroundColor:[UIColor clearColor]
                                                     textColor:[UIColor greenColor]
                                                         state:YES];
                if (!strongSelf.processLayer) {
                    strongSelf.processLayer = [CALayer layer];
                    strongSelf.processLayer.bounds =
                            CGRectMake(0, 0, CGRectGetWidth(strongSelf.preview.bounds), 5);
                    strongSelf.processLayer.position =
                            CGPointMake(CGRectGetMidX(strongSelf.preview.bounds),
                                        CGRectGetHeight(strongSelf.preview.bounds) - 2.5);
                    strongSelf.processLayer.backgroundColor = [UIColor greenColor].CGColor;
                }
                [strongSelf addAnimation];
                [strongSelf.preview.layer addSublayer:strongSelf.processLayer];
                [strongSelf.longPressButton disappearAnimation];
                break;
            }
            case WKStateIn: {
                [strongSelf showStatusLabelWithBackgroundColor:[UIColor clearColor]
                                                     textColor:[UIColor greenColor]
                                                         state:YES];
                break;
            }
            case WKStateOut: {
                [strongSelf showStatusLabelWithBackgroundColor:[UIColor redColor]
                                                     textColor:[UIColor whiteColor]
                                                         state:NO];
                break;
            }
            case WKStateCancle: {
                [strongSelf.recorder cancleCaputre];
                [strongSelf endRecord];
                [strongSelf popSelf];
                break;
            }
            case WKStateFinish: {
                [strongSelf.recorder stopCapture];
                [strongSelf endRecord];
                [strongSelf popSelf];
                break;
            }
        }
    }];
}

//双击 焦距调整
- (void)tapGR:(UITapGestureRecognizer *)tapGes {
    CGFloat scaleFactor = self.isScale ? 1 : 2.f;

    self.scale = !self.isScale;

    [_recorder setScaleFactor:scaleFactor];
}

- (void)showStatusLabelWithBackgroundColor:(UIColor *)color
                                 textColor:(UIColor *)textColor
                                     state:(BOOL)isIn {
    _statusLabel.backgroundColor = color;
    _statusLabel.textColor = textColor;
    _statusLabel.hidden = NO;

    _statusLabel.text = isIn ? JXUIString(@"move up to cancel") : JXUIString(@"release to cancel");
}

- (void)endRecord {
    [_processLayer removeAllAnimations];
    _processLayer.hidden = YES;
    _statusLabel.hidden = YES;
    [self.longPressButton appearAnimation];
}

- (void)addAnimation {
    _processLayer.hidden = NO;
    _processLayer.backgroundColor = [UIColor cyanColor].CGColor;

    CABasicAnimation *scaleXAnimation =
            [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleXAnimation.duration = 15.f;
    scaleXAnimation.fromValue = @(1.f);
    scaleXAnimation.toValue = @(0.f);

    [_processLayer addAnimation:scaleXAnimation forKey:@"scaleXAnimation"];
}

#pragma mark - Orientation
- (void)viewWillTransitionToSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // Note that the app delegate controls the device orientation notifications required to use the
    // device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) ||
        UIDeviceOrientationIsLandscape(deviceOrientation)) {
        AVCaptureVideoPreviewLayer *previewLayer = [_recorder getPreviewLayer];
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;

        UIInterfaceOrientation statusBarOrientation =
                [UIApplication sharedApplication].statusBarOrientation;
        AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
        if (statusBarOrientation != UIInterfaceOrientationUnknown) {
            initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
        }

        [_recorder videoConnection].videoOrientation = initialVideoOrientation;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
        NS_DEPRECATED_IOS(2_0, 8_0,
                          "Implement viewWillTransitionToSize:withTransitionCoordinator: instead")
                __TVOS_PROHIBITED {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) ||
        UIDeviceOrientationIsLandscape(deviceOrientation)) {
        AVCaptureVideoPreviewLayer *previewLayer = [_recorder getPreviewLayer];
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;

        UIInterfaceOrientation statusBarOrientation =
                [UIApplication sharedApplication].statusBarOrientation;
        AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
        if (statusBarOrientation != UIInterfaceOrientationUnknown) {
            initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
        }

        [_recorder videoConnection].videoOrientation = initialVideoOrientation;
    }
}

#pragma mark - lazy load

- (UIView *)preview {
    if (!_preview) {
        _preview = [[UIView alloc] init];
        _preview.translatesAutoresizingMaskIntoConstraints = NO;
        _preview.backgroundColor = [UIColor blackColor];
        // 针对iOS7，需要提前给大小，否则会出现黑屏
        CGSize size = [UIScreen mainScreen].bounds.size;
        _preview.jx_size = CGSizeMake(size.width, size.height - 100);
    }
    return _preview;
}

- (UIImageView *)focusImageView {
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc] initWithImage:JXChatImage(@"sight_video_focus")];
        _focusImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _focusImageView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.font = [UIFont systemFontOfSize:17.f];
        _statusLabel.textColor = [UIColor greenColor];
    }
    return _statusLabel;
}

- (JXVideoShootButton *)longPressButton {
    if (!_longPressButton) {
        _longPressButton = [[JXVideoShootButton alloc] init];
        _longPressButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _longPressButton;
}

@end
