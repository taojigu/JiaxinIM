//
//  JXRemindHelper.h
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define sJXReminder [JXReminder sharedInstance]

typedef NS_ENUM(UInt32, JXSystemRemindVoiceType) {
    kSystemRemindVoiceTypeVibrate = kSystemSoundID_Vibrate,    //<只震动
    kSystemRemindVoiceTypeRemind = 1000,                       //<叮一声
    kSystemRemindVoiceTypeMessage = 1002,                      //<叮当
    kSystemRemindVoiceTypeMessageSend = 1004,
    kSystemRemindVoiceTypeAudioToneCallWaiting = 1074,
    kSystemRemindVoiceTypeDuDu = 1152,       //<中断连接嘟嘟声
    kSystemRemindVoiceTypeCalling = 1153,    //<正在连接中
    kSystemRemindVoiceTypeNone = 0
};

@interface JXReminder : NSObject

+ (instancetype)sharedInstance;

+ (void)playVoiceWithType:(JXSystemRemindVoiceType)voiceType;

- (void)playRepeatVoiceWithType:(JXSystemRemindVoiceType)voiceType;

- (void)stopRepeatPlay;

@end
