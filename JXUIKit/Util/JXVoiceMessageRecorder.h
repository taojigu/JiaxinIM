//
//  JXVoiceMessageRecorder.h
//

#import <Foundation/Foundation.h>

typedef enum {
    JXRecordErrorTypeNone,
    JXRecordErrorTypeRecordTimeToShort,
    JXRecordErrorTypeConvertVoiceFormatFailed,
    JXRecordErrorTypeRecordNotBegin
}JXRecordErrorType;

@interface JXVoiceMessageRecorder : NSObject

@property(nonatomic, copy) dispatch_block_t maxTimeStopRecorderCompletion;
@property(nonatomic, assign) NSTimeInterval recordDuration;
@property(nonatomic, assign) NSInteger maxRecordTime;
@property(nonatomic, assign) BOOL isCancelled;
@property(nonatomic, copy, readonly) NSString *recordPath;
@property (nonatomic, assign, readonly) double currentVolume; // 录音当前音量

- (BOOL)canRecord;
- (void)prepareWithFilePath:(NSString *)path andCompletion:(dispatch_block_t)completion;
- (void)startWithCompletion:(dispatch_block_t)completion;
- (void)stopWithCompletion:(void (^)(JXRecordErrorType type))completion;
- (void)cancelCurrentRecord;

@end
