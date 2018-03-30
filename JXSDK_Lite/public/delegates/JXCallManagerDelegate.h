//
//  JXManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXVideoView.h"

@protocol JXCallManagerDelegate<JXBaseDelegate>

@optional

/*!
 @method
 @brief 接收到来电的回调
 @discussion
 @param from         来电号码
 @param callType     通话类型
 @result
 */
- (void)didReceivingCallFrom:(NSString *)from withType:(JXCallType)callType;

/*!
 @method
 @brief 呼叫电话正忙的回调
 @discussion
 @result
 */
- (void)didCallBusy;

/*!
 @method
 @brief 主动呼叫电话响铃的回调
 @discussion
 @result
 */
- (void)didCallRinging;

/*!
 @method
 @brief 呼叫电话已经被接听的回调
 @discussion
 @result
 */
- (void)didCallAccepted;

/*!
 @method
 @brief 呼叫电话已经连接的回调
 @discussion
 @result
 */
- (void)didCallConnected;

/*!
 @method
 @brief 呼叫电话已经断开连接的回调
 @param error     错误类型
 @discussion
 @result
 */
- (void)didCallDisconnectedWithError:(JXErrorType)error;

/*!
 @method
 @brief 视频画面改变的回调
 @param videoView     视频画面
 @param size          尺寸
 @discussion
 @result
 */
- (void)didVideoView:(JXVideoView *)videoView changeSize:(CGSize)size;

@end
