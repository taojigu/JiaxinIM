//
//  JXCallManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"

@class JXVideoView;
@protocol ICallManager<IBaseManager>

/*!
 @class
 @brief 远程呼叫
 */
@property(nonatomic, readonly) NSString *remoteParty;

/*!
 @class
 @brief 呼叫类型 （音频呼叫，视频呼叫。。。）
 */
@property(nonatomic, readonly) JXCallType activeCallType;

/*!
 @method
 @brief  打电话
 @discussion
 @param userName  用户名
 @param type   呼叫类型 （音频呼叫，视频呼叫。。。）
 @result
 */
- (BOOL)makeCall:(NSString *)username withType:(JXCallType)type;

/*!
 @method
 @brief  设置远程视频画面和本地视频画面
 @discussion
 @param remote  远程视频画面
 @param local   本地视频画面
 @result
 */
- (void)setRemoteVideoView:(JXVideoView *)remote andLocal:(JXVideoView *)local;

/*!
 @method
 @brief  判断呼叫是否正忙
 @discussion
 @result BOOL （yes 为正忙， no 为不忙）
 */
- (BOOL)isBusy;

/*!
 @method
 @brief  接听来电
 @discussion
 @result
 */
- (void)accept;

/*!
 @method
 @brief  拒绝来电
 @discussion
 @result
 */
- (void)reject;

/*!
 @method
 @brief  挂断电话
 @discussion
 @result
 */
- (void)hangup;

/*!
 @method
 @brief  切换摄像头
 @discussion
 @result
 */
- (void)switchCamera;

/*!
 @method
 @brief  静音
 @discussion
 @result
 */
- (void)mute;

/*!
 @method
 @brief  不静音
 @discussion
 @result
 */
- (void)unMute;

/*!
 @method
 @brief  使用扬声器
 @discussion
 @param enable   是否使用扬声器 （yes 为使用， no w为不使用）
 @result BOOL （yes 为设置成功，no 为设置失败）
 */
- (BOOL)enableSpeaker:(BOOL)enable;

/*!
 @method
 @brief  使用后置摄像头
 @discussion
 @result BOOL （yes 为设置成功，no 为设置失败）
 */
- (BOOL)useBackCamera;

@end
