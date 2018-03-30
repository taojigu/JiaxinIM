//
//  WKMovieRecorder.h
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

extern const NSString *const JXRecorderLastFrame;
extern const NSString *const JXRecorderMovieURL;
extern const NSString *const JXRecorderDuration;
extern const NSString *const JXRecorderAllFrames;
extern const NSString *const JXRecorderFirstFrame;

typedef NS_ENUM(NSInteger, JXRecorderFinishedReason) {
    JXRecorderFinishedReasonNormal,              //主动结束
    JXRecorderFinishedReasonCancle,              //取消
    JXRecorderFinishedReasonBeyondMaxDuration    //超时结束
};

/**
 *  录制结束
 *
 *  @param info     回调信息
 *  @param isCancle YES:取消 NO:正常结束
 */
typedef void (^FinishRecordingBlock)(NSDictionary *info, JXRecorderFinishedReason finishReason);
/**
 *  焦点改变
 */
typedef void (^FocusAreaDidChanged)(void);
/**
 *  权限验证
 *
 *  @param success 是否成功
 */
typedef void (^AuthorizationResult)(BOOL success);

@interface JXMovieRecorder : NSObject

+ (JXMovieRecorder *)sharedRecorder;
- (void)setup;
- (void)shutdown;
- (AVCaptureVideoPreviewLayer *)getPreviewLayer;
- (void)prepareCaptureWithBlock:(void (^)(void))block;
- (void)startCapture;
- (void)pauseCapture;
- (void)stopCapture;
- (void)cancleCaputre;
- (void)resumeCapture;
- (void)startSession;                      //启动session
- (BOOL)setScaleFactor:(CGFloat)factor;    //设置缩放
- (void)changeCamera;
- (void)finishCapture;

//回调
@property(nonatomic, copy) FinishRecordingBlock finishBlock;    //录制结束回调
@property(nonatomic, copy) FocusAreaDidChanged focusAreaDidChangedBlock;
@property(nonatomic, copy) AuthorizationResult authorizationResultBlock;

- (instancetype)initWithMaxDuration:(NSTimeInterval)duration;

@property(nonatomic, strong, readonly) AVCaptureConnection *videoConnection;
@property(nonatomic, strong, readonly) AVCaptureConnection *audioConnection;
@property(nonatomic, strong, readonly) AVCaptureDeviceInput *videoDeviceInput;
@property(nonatomic, assign, readonly) NSTimeInterval duration;
@property(nonatomic, strong, readonly) NSURL *recordURL;    //临时视频地址

@property(nonatomic, assign) CGSize cropSize;

@property(nonatomic, assign, readonly) BOOL isCapturing;

@end
