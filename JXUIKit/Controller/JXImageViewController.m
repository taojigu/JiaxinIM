//
//  JXImageViewController.m
//

#import "JXImageViewController.h"

#import "JXHUD.h"
#import "JXMessageFileDownloader.h"
#import "JXSDPieLoopProgressView.h"
#import "UIImage+Extensions.h"

@interface JXImageViewController ()<UIScrollViewDelegate, JXMessageFileDownloaderDelegate>

@property(nonatomic, strong) JXMessage *message;
@property(nonatomic, strong) UIImageView *contentView;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) JXSDPieLoopProgressView *progressView;

@end

@implementation JXImageViewController

- (instancetype)initWithMessage:(JXMessage *)message {
    if (self = [super init]) {
        _message = message;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hideNavBar = YES;
    self.view.backgroundColor = [UIColor blackColor];

    [JXMessageFileDownloader addDownloadStatusObserver:self];
    NSData *imgData = [NSData dataWithContentsOfFile:self.message.localURL];
    if ([imgData length] < self.message.fileSize || (self.message.fileSize == 0 && [imgData length] <= 0)) {
        _progressView = [[JXSDPieLoopProgressView alloc] initWithFrame:self.view.frame];
        _progressView.jx_width = 100;
        _progressView.jx_height = 100;
        _progressView.center = self.view.center;
        if (![JXMessageFileDownloader isDownloadingMessage:self.message.messageId]) {
            [JXMessageFileDownloader downloadFileForMessage:self.message];
        }
    }

    CGRect selfFrame = self.view.frame;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:selfFrame];
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 2.0;
    scrollView.scrollEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [scrollView addGestureRecognizer:tapGestureRecognizer];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:selfFrame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView = imageView;
    [self setImageView];

    [scrollView addSubview:self.contentView];
    [scrollView addSubview:_progressView];
    [self.view addSubview:scrollView];
}

- (void)setImageView {
    NSData *imgData = [NSData dataWithContentsOfFile:self.message.localURL];
    if (!imgData) {
        imgData = [NSData dataWithContentsOfFile:self.message.thumbUrlToDisplay];
    }
    self.contentView.image = [UIImage animatedImageWithAnimatedGIFData:imgData];
}

- (void)resetImageFrame {
    UIImage *image = self.contentView.image;
    CGFloat scale = image.size.height / image.size.width;
    if (!image) {
        scale = 0;
    }

    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = width * scale;
    NSInteger top = 0;
    if (scale < 1 || height < self.view.frame.size.height) {
        top = fabs(self.view.frame.size.height - height) * 0.5;
    }
    if (height) {
        self.contentView.frame = CGRectMake(0, top, width, height);
    }
}

- (void)viewDidPop {
    [super viewDidPop];
    [JXMessageFileDownloader removeDownloadStatusObserver:self];
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - JXMessageFileDownloadHelperDelegate

- (void)didMessage:(NSString *)messageID updateProgress:(float)progress {
    if (messageID != self.message.messageId) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.progress = progress;
    });
}

//下载成功
- (void)messageFileDownloadSuccesed:(NSString *)messageID {
    if (messageID != self.message.messageId) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView dismiss];
        [self setImageView];
        [self resetImageFrame];
    });
}

- (void)messageFileDownloadFailed:(NSString *)messageID {
    if (messageID != self.message.messageId) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        sJXHUDMes(@"fail to download", 1.5);
    });
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self resetImageFrame];
}

@end
