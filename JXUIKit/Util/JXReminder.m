//
//  JXRemindHelper.m
//

#import "JXReminder.h"

@interface JXReminder ()

@property(nonatomic, strong) NSTimer *playTimer;
@property(nonatomic, assign) JXSystemRemindVoiceType playingVoiceType;

@end

@implementation JXReminder

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)playVoiceWithType:(JXSystemRemindVoiceType)voiceType {
    AudioServicesPlaySystemSound(voiceType);
}

- (void)playRepeatVoiceWithType:(JXSystemRemindVoiceType)voiceType {
    self.playingVoiceType = voiceType;
    NSTimeInterval timeInterval = 3;
    if (kSystemRemindVoiceTypeCalling == voiceType) {
        timeInterval = 4;
    }
    AudioServicesPlaySystemSound(voiceType);
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                  target:self
                                                selector:@selector(repeatPlayVoice)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)repeatPlayVoice {
    AudioServicesPlaySystemSound(self.playingVoiceType);
}

- (void)stopRepeatPlay {
    [_playTimer invalidate];
    self.playingVoiceType = kSystemRemindVoiceTypeNone;
    _playTimer = nil;
}

@end
