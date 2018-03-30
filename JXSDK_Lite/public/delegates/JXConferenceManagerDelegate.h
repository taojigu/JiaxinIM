//
//  JXConferenceManagerDelegate.h
//  JXSDK
//
//  Created by YuSong.Yan on 16/2/17.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXConferenceMember.h"

@protocol JXConferenceManagerDelegate<JXBaseDelegate>

@optional

/*!
 @method
 @brief 接收到会议邀请的回调
 @discussion
 @param from         会议发起的群组
 @param callType     会议类型
 @result
 */
- (void)didConferenceIncomming:(NSString *)from withType:(JXCallType)conferenceType;

/*!
 @method
 @brief 会议正忙的回调
 @discussion
 @result
 */
- (void)didConferenceBusy;

/*!
 @method
 @brief 会议已经连接的回调
 @discussion
 @result
 */
- (void)didConferenceConnected;

/*!
 @method
 @brief 会议断开连接的回调
 @param error     错误类型
 @discussion
 @result
 */
- (void)didConferenceDisconnectedWithError:(JXErrorType)error;

/*!
 @method
 @brief 视频画面改变的回调
 @param videoView     视频画面
 @param size          尺寸
 @discussion
 @result
 */
- (void)didConferenceVideoView:(JXVideoView *)videoView changeSize:(CGSize)size;

/*!
 @method
 @brief 会议成员加入会议（接受会议邀请）
 @param memberID     会议成员ID
 @discussion
 @result
 */
- (void)didMemberJoined:(JXConferenceMember *)conferenceMember;

/*!
 @method
 @brief 会议成员离开会议（会退出议）
 @param memberID     会议成员ID
 @discussion
 @result
 */
- (void)didMemberDeparted:(JXConferenceMember *)conferenceMember;

/*!
 @method
 @brief 有新成员被邀请的回调
 @param confenceMember     会议成员ID
 @discussion
 @result
 */
- (void)didAddParticipants:(NSArray *)confenceMembers;

/*!
 @method
 @brief 会议发起者取消会议
 @discussion
 @result
 */
- (void)didModeratorCancelConference;

@end
