//
//  JXVoiceMessagePlayer.mm
//

#import "JXVoiceMessagePlayer.h"
#import "JXMacros.h"
#import "NSString+Extends.h"
#import "amrFileCodec.h"

@interface JXVoiceMessagePlayer ()<AVAudioPlayerDelegate>
@property(nonatomic, strong) NSMutableArray *oberverList;
@end

@implementation JXVoiceMessagePlayer

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (BOOL)convertWAVE:(NSString *)strWavePath ToAmr:(NSString *)toAmrPath {
    if ([NSString isBlankString:strWavePath] || [NSString isBlankString:toAmrPath]) {
        return NO;
    }

    int frames = EncodeWAVEFileToAMRFile([strWavePath UTF8String], [toAmrPath UTF8String], 1, 16);
    if (frames > 0) {
        // succeed.
        return YES;
    }
    return NO;
}

- (void)addVoiceMessagePlayerObsever:(id<JXVoiceMessagePlayerDelegate>)observer {
    if (!_oberverList) {
        _oberverList = [NSMutableArray array];
    }
    [_oberverList addObject:observer];
}

- (void)removeVoiceMessagePlayerObsever:(id<JXVoiceMessagePlayerDelegate>)observer {
    if (!self.oberverList) {
        return;
    }
    if (observer && [self.oberverList containsObject:observer]) {
        [self.oberverList removeObject:observer];
    }
}

+ (double)durationForAudioFile:(NSString *)filePath {
    double tmp = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        CMTime time = asset.duration;
        tmp = CMTimeGetSeconds(time);
    }
    return tmp;
}

- (void)playAudioWithFilePath:(NSString *)audioFilePath messageID:(NSString *)messageID {
    if (self.audioPlayer.isPlaying) {
        NSString *lastMessageID = [self.playingAudioMessageID copy];
        [self playAudioFinished];
        if ([messageID isEqualToString:lastMessageID]) {
            return;
        }
    }
    if (!messageID) return;

    self.playingAudioMessageID = messageID;
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
        [self playAudioFailedWithReason:@"audio file not found"];
        return;
    }

    NSURL *url = [NSURL fileURLWithPath:audioFilePath];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    if (url) {
        NSString *cachePath = NSTemporaryDirectory();
        NSString *strTempWav = [cachePath stringByAppendingString:@"Temp.wav"];
        BOOL isSucceed =
                DecodeAMRFileToWAVEFile([audioFilePath UTF8String], [strTempWav UTF8String]);
        if (isSucceed) {
            self.audioPlayer =
                    [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strTempWav]
                                                           error:nil];
            self.audioPlayer.delegate = self;
            [self.audioPlayer play];
        } else {
            [self playAudioFailedWithReason:@"failed to play audio!"];
        }
    }
}

- (void)stopPlayAudio {
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        [self playAudioFinished];
    }
}
- (void)playAudioFinished {
    for (id observer in _oberverList) {
        if (observer &&
            [observer respondsToSelector:@selector(audioFilePlayFinishedWithMessageID:)]) {
            [observer audioFilePlayFinishedWithMessageID:self.playingAudioMessageID];
        }
    }
    [self.audioPlayer stop];
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
    self.playingAudioMessageID = nil;
}

- (void)playAudioFailedWithReason:(NSString *)erroReason {
    for (id observer in _oberverList) {
        if (observer &&
            [observer respondsToSelector:@selector(audioFilePlayFailedWithMessageID:error:)]) {
            [observer audioFilePlayFailedWithMessageID:self.playingAudioMessageID error:erroReason];
        }
    }
    [self.audioPlayer stop];
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
    self.playingAudioMessageID = nil;
}

#pragma mark -
#pragma mark -  AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self playAudioFinished];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self playAudioFailedWithReason:@"failed to play audio!"];
}

@end
