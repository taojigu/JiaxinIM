//
// JXVoiceRecordView.m
//

#import "JXSDKHelper.h"
#import "JXVoiceRecordView.h"

#define DefaultColor [UIColor colorWithWhite:0.88 alpha:1]
#define HighlightColor [UIColor colorWithWhite:0.9 alpha:1]

@interface JXRecordView ()

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) UIView *bkgView;
@property(nonatomic, strong) UIImageView *microPhoneView;
@property(nonatomic, strong) UIImageView *recordAnimationView;
@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) NSArray *animationImages;
@property(nonatomic, strong) UIView *timeToShortView;

@end

@implementation JXRecordView

+ (void)initialize {
    // UIAppearance Proxy Defaults
    JXRecordView *recordView = [self appearance];
    recordView.voiceMessageAnimationImages = @[];
    recordView.upCancelText = JXUIString(@"move up to cancel");
    recordView.loosenCancelText = JXUIString(@"release to cancel");
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)dealloc {
    JXLog(@"%s", __FUNCTION__);
}

#pragma mark - setter

- (void)setVoiceMessageAnimationImages:(NSArray *)voiceMessageAnimationImages {
    _voiceMessageAnimationImages = voiceMessageAnimationImages;
}

- (void)setUpCancelText:(NSString *)upCancelText {
    _upCancelText = upCancelText;
    _textLabel.text = _upCancelText;
}

- (void)setLoosenCancelText:(NSString *)loosenCancelText {
    _loosenCancelText = loosenCancelText;
}

#pragma mark - public

// 录音按钮按下
- (void)recordButtonTouchDown {
    self.backgroundColor = HighlightColor;
    // 需要根据声音大小切换recordView动画
    _textLabel.text = _upCancelText;
    _textLabel.backgroundColor = [UIColor clearColor];
    WEAKSELF;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                               block:^{
                                                   [weakSelf setupRecordImage];
                                               }
                                             repeats:YES];
}

// 手指在录音按钮内部时离开
- (void)recordButtonTouchUpInside {
    self.backgroundColor = DefaultColor;
    [self.recordAnimationView stopAnimating];
    [_timer invalidate];
    _timer = nil;
}

// 手指在录音按钮外部时离开
- (void)recordButtonTouchUpOutside {
    [_timer invalidate];
    _timer = nil;
}

// 手指移动到录音按钮内部
- (void)recordButtonDragInside {
    _textLabel.text = _upCancelText;
    _textLabel.backgroundColor = [UIColor clearColor];
}

// 手指移动到录音按钮外部
- (void)recordButtonDragOutside {
    _textLabel.text = _loosenCancelText;
    _textLabel.backgroundColor = [UIColor redColor];
}

// TODO:显示录音时间过短
- (void)showRecordTimeToShortImage {
    //    self.microPhoneView.image = JXChatImage(@"ic_recording_too_short_hint");
    //    self.recordAnimationView.hidden = YES;
    //    [self.recordAnimationView removeFromSuperview];
    self.timeToShortView.hidden = NO;
    self.timeToShortView.alpha = 1.0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.timeToShortView.alpha = 0;
                         //        self.timeToShortView.hidden = YES;
                     }];
}

- (void)setupRecordImage {
    if ([self.delegate respondsToSelector:@selector(currentVolume)]) {
        double volume = [self.delegate currentVolume];
        if (volume < 0.2) {
            self.recordAnimationView.image = self.animationImages[0];
        } else if (volume < 0.4) {
            self.recordAnimationView.image = self.animationImages[1];
        } else if (volume < 0.6) {
            self.recordAnimationView.image = self.animationImages[2];
        } else if (volume < 0.8) {
            self.recordAnimationView.image = self.animationImages[3];
        } else {
            self.recordAnimationView.image = self.animationImages.lastObject;
        }
    }
}

#pragma mark - private

- (void)setupSubViews {
    [self addSubview:self.bkgView];
    [self addSubview:self.microPhoneView];
    [self.microPhoneView addSubview:self.recordAnimationView];
    [self.microPhoneView addSubview:self.textLabel];
    [self addSubview:self.timeToShortView];

    NSDictionary *views = @{
        @"bkview" : self.bkgView,
        @"micview" : self.microPhoneView,
        @"recordview" : self.recordAnimationView,
        @"text" : self.textLabel,
        @"timeView" : self.timeToShortView
    };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bkview]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bkview]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[micview]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[micview]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[recordview]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                                     @"V:|-40-[recordview]-10-[text(25)]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[text]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[timeView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[timeView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

#pragma mark - getter
// 背景
- (UIView *)bkgView {
    if (_bkgView == nil) {
        _bkgView = [[UIView alloc] initWithFrame:self.bounds];
        _bkgView.backgroundColor = [UIColor darkGrayColor];
        _bkgView.layer.cornerRadius = 5;
        _bkgView.layer.masksToBounds = YES;
        _bkgView.alpha = 0.6;
        _bkgView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bkgView;
}

- (UIImageView *)microPhoneView {
    if (_microPhoneView == nil) {
        _microPhoneView = [[UIImageView alloc] initWithImage:JXChatImage(@"ic_mic")];
        _microPhoneView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _microPhoneView;
}

- (UIImageView *)recordAnimationView {
    if (_recordAnimationView == nil) {
        _recordAnimationView = [[UIImageView alloc] init];
        // _recordAnimationView.image = self.animationImages.lastObject;
        _recordAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        _recordAnimationView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _recordAnimationView;
}

- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = self.upCancelText;
        _textLabel.font = [UIFont systemFontOfSize:13];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.layer.cornerRadius = 5;
        _textLabel.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        _textLabel.layer.masksToBounds = YES;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textLabel;
}

- (UIView *)timeToShortView {
    if (_timeToShortView == nil) {
        _timeToShortView = [[UIView alloc] init];
        _timeToShortView.backgroundColor = [UIColor darkGrayColor];
        UIImageView *imageView =
                [[UIImageView alloc] initWithImage:JXChatImage(@"ic_recording_too_short_hint")];
        imageView.frame = _timeToShortView.bounds;
        [_timeToShortView addSubview:imageView];
        _timeToShortView.hidden = YES;
        _timeToShortView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _timeToShortView;
}

- (NSArray *)animationImages {
    if (_animationImages == nil) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i = 1; i < 5; ++i) {
            NSString *tempString = [NSString stringWithFormat:@"ic_voic_amplitude_%d", i];
            UIImage *image = JXChatImage(tempString);
            [tempArr addObject:image];
        }
        _animationImages = tempArr;
    }
    return _animationImages;
}

@end
