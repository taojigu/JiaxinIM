//
//  JXVoiceMessagePlayer.h
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define sVoiceMessagePlayer [JXVoiceMessagePlayer sharedInstance]

@protocol JXVoiceMessagePlayerDelegate<NSObject>

- (void)audioFilePlayFinishedWithMessageID:(NSString *)messageID;
- (void)audioFilePlayFailedWithMessageID:(NSString *)messageID error:(NSString *)error;

@end

@interface JXVoiceMessagePlayer : NSObject

@property(nonatomic, copy) NSString *playingAudioMessageID;
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;

+ (instancetype)sharedInstance;
+ (double)durationForAudioFile:(NSString *)filePath;

+ (BOOL)convertWAVE:(NSString *)strWavePath ToAmr:(NSString *)toAmrPath;

- (void)addVoiceMessagePlayerObsever:(id<JXVoiceMessagePlayerDelegate>)observer;
- (void)removeVoiceMessagePlayerObsever:(id<JXVoiceMessagePlayerDelegate>)observer;

- (void)playAudioWithFilePath:(NSString *)audioFilePath messageID:(NSString *)messageID;
- (void)stopPlayAudio;

@end
