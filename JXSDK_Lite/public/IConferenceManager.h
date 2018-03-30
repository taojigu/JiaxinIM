//
//  IConferenceManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"
#import "JXGroup.h"

@protocol IConferenceManager<IBaseManager>

/*!
 @class
 @brief 群ID
 */
@property(nonatomic, readonly) NSString *groupID;

/*!
 @class  array of  Conference Manager
 @brief 会议成员
 */
@property(nonatomic, readonly) NSMutableArray *participants;

/*!
 @class
 @brief 会议发起者
 */
@property(nonatomic, readonly) NSString *moderator;

/*!
 @class
 @brief 会议类型
 */
@property(nonatomic, readonly) JXCallType activeCallType;

/*!
 @method
 @brief  创建会议
 @discussion
 @param group       指定会议的群
 @param type        会议类型，只能为JXCallTypeAudioConf或JXCallTypeVideoConf
 @param members     会议成员，list of  JXConferenceModel class
 @result
 */
- (BOOL)createConferenceInGroup:(JXGroup *)group
                       withType:(JXCallType)type
                        Members:(NSArray *)members;


/*!
 @method
 @brief  //邀请会议成员
 @discussion
 @param members     会议成员，list of  JXConferenceModel class
 @result
 */
- (void)inviteMembers:(NSArray *)members;

//同意会议
- (void)acceptJoinConference;

//拒绝会议
- (void)rejectJoinConference;

//退出会议
- (void)endConference;

@end