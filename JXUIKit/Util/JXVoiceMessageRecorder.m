//
//  JXVoiceMessageRecorder.m
//

#import "JXVoiceMessageRecorder.h"
#import "JXMacros.h"
#import "JXVoiceMessagePlayer.h"

//#import "amrFileCodec.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#define kIMMessageVoiceMaxRecordTime 60.0

@interface JXVoiceMessageRecorder ()<AVAudioRecorderDelegate> {
    NSTimer *_timer;
}

@property(nonatomic, copy) NSString *recordPath;
@property(nonatomic, strong) NSDate *recordStartTime;
@property(nonatomic, strong) NSDate *recordEndTime;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, copy) void (^compelete)(JXRecordErrorType);

@end

@implementation JXVoiceMessageRecorder

- (id)init {
    self = [super init];
    if (self) {
        self.maxRecordTime = kIMMessageVoiceMaxRecordTime;
        self.recordDuration = 0;
    }
    return self;
}

- (void)dealloc {
    [self stopRecord];
    self.recordPath = nil;
}

- (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    if (IOSVersion >= 7.0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:)
                               withObject:^(BOOL granted) {
                                   bCanRecord = granted;
                               }];
        }
    }

    return bCanRecord;
}

- (void)prepareWithFilePath:(NSString *)path andCompletion:(dispatch_block_t)completion {
    if (self.recorder) {
        [self cancelCurrentRecord];
    }

    if (!path) {
        NSAssert(path != nil, @"file path can not be empty!");
    }

    if (![self canRecord]) {
        return;
    }

    // 拼接路径
    NSString *recordPath = NSTemporaryDirectory();
    recordPath = [recordPath stringByAppendingPathComponent:path];
    NSString *wavFilePath =
            [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    self.recordPath = wavFilePath;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];

        NSDictionary *settings = @{
            AVSampleRateKey : @8000.0,
            AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatLinearPCM],
            AVLinearPCMBitDepthKey : @16,
            AVNumberOfChannelsKey : @1
        };
        self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordPath]
                                                    settings:settings
                                                       error:nil];
        self.recorder.delegate = self;
        [self.recorder prepareToRecord];
        [self.recorder setMeteringEnabled:YES];
        [self.recorder recordForDuration:self.maxRecordTime];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)startWithCompletion:(dispatch_block_t)startRecorderCompletion {
    if ([self.recorder record]) {
        //初始化定时器，用以更新录音进度
        //[self resetTimer];
        //_timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
        //                                          target:self
        //                                        selector:@selector(updateRecordProgress)
        //                                        userInfo:nil
        //                                         repeats:YES];
        self.recordStartTime = [NSDate date];
        if (startRecorderCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                startRecorderCompletion();
            });
        }
    }
}

- (void)stopWithCompletion:(void (^)(JXRecordErrorType))completion {
    self.compelete = completion;
    // 没有回调直接返回
    if (!completion) {
        return;
    }
    // 录音没有开始
    if (![self.recorder isRecording]) {
        completion(JXRecordErrorTypeRecordNotBegin);
        return;
    }

    // 录音时间过短
    self.recordEndTime = [NSDate date];    // 记录结束时间
    if ([self.recordEndTime timeIntervalSinceDate:self.recordStartTime] < 1.0) {
        completion(JXRecordErrorTypeRecordTimeToShort);
        // 延迟一秒结束录音
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self.recorder stop];
                       });
        // 删除war文件
        [self removeRecordFile:self.recordPath];
        return;
    }
    // 录音成功
    [self.recorder stop];
}

- (void)cancelCurrentRecord {
    if ([self.recorder isRecording]) {
        [self stopRecord];
    }

    if (self.recordPath) {
        // 删除目录下的文件
        [self removeRecordFile:self.recordPath];
    }
}

/**
 *  得到录音总时长
 *
 *  @param recordPath 录音文件路径
 */
- (NSTimeInterval)voiceDuration:(NSString *)recordPath {
    NSError *error = nil;
    AVAudioPlayer *play =
            [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath]
                                                   error:&error];
    if (error) {
        JXLog(@"recordPath：%@ error：%@", recordPath, error);
        return -1;
    } else {
        JXLog(@"record time interval:%f", play.duration);
        return play.duration;
    }
}

- (void)resetRecorder {
    if (_recorder) {
        _recorder.delegate = nil;
        if (_recorder.isRecording) {
            [_recorder stop];
        }
        _recorder = nil;
    }
}

- (void)stopRecord {
    [self resetRecorder];
}

- (void)removeRecordFile:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName]) {
        [fileManager removeItemAtPath:fileName error:nil];
    } else {
        return;
    }
}

- (double)currentVolume {
    double ret = 0.0;
    if ([self.recorder isRecording]) {
        [self.recorder updateMeters];
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
        ret = lowPassResults;
    }

    return ret;
}

#pragma mark - AVAudioRecorderDelegate method
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    JXLog(@"%@", recorder);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *amrPath = [[self.recordPath stringByDeletingPathExtension]
                stringByAppendingPathExtension:@"amr"];

        BOOL suc = [JXVoiceMessagePlayer convertWAVE:self.recordPath ToAmr:amrPath];

        self.recordDuration = [self voiceDuration:self.recordPath];
        // 删除war文件
        [self removeRecordFile:self.recordPath];
        self.recordPath = amrPath;

        if (self.recordDuration < 0) suc = NO;

        if (suc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.recordDuration < self.maxRecordTime && self.compelete) {
                    self.compelete(JXRecordErrorTypeNone);
                } else if (self.recordDuration >= self.maxRecordTime &&
                           self.maxTimeStopRecorderCompletion) {
                    self.maxTimeStopRecorderCompletion();
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.compelete(JXRecordErrorTypeConvertVoiceFormatFailed);
            });
        }
    });
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"%@", error);
}

@end
