//
//  JXGroupManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXGroup.h"
#import "JXGroupMember.h"

@protocol JXGroupManagerDelegate<JXBaseDelegate>

@optional

/*!
 @method
 @brief 主动创建群组的回调
 @discussion
 @param group       群组对象
 @param error       错误信息
 @result
 */
- (void)group:(JXGroup *)group didCreateWithError:(JXError *)error;

/*!
 @method
 @brief 主动加入群组的回调
 @discussion
 @param group       群组对象
 @param error       错误信息
 @result
 */
- (void)group:(JXGroup *)group didJoinWithError:(JXError *)error;

/*!
 @method
 @brief 当用户正常在线时被邀请进群时回调
 @discussion
 @param group     群组对象
 @param username  邀请人
 @param isAccept  是否接受 (yes为接受，no为不接受)
 @result
 */
- (void)groupDidInvited:(JXGroup *)group from:(NSString *)username isAccept:(BOOL)isAccept;

/*!
 @method
 @brief 当前用户离开一个群组后的回调
 @discussion 离开的原因包含主动退出, 被别人请出, 和销毁群组三种情况
 @param group  所要离开的群组对象
 @param reason 离开的原因
 @param error  错误信息
 @result
 */
- (void)group:(JXGroup *)group didLeave:(JXGroupLeaveReason)reason error:(JXError *)error;

/*!
 @method
 @brief 有人被邀请或者有人被踢出的回调
 @discussion
 @param group  群组对象
 @param member 群成员对象
 @param type   群成员变化类型
 @result
 */
- (void)group:(JXGroup *)group
        didMemberChange:(JXGroupMember *)member
                   type:(JXGroupMemberChangeType)type;

/*!
 @method
 @brief 群组成员列表更新的回调
 @discussion
 @param group  群组对象
 @param membersList 群成员列表
 @result
 */
- (void)group:(JXGroup *)group didMemberListUpdate:(NSArray *)membersList;

/*!
 @method
 @brief 获取群组成员列表后的回调
 @discussion
 @param occupantsList 群组成员列表（创建者）
 @param error         错误信息
 @result
 */
- (void)group:(JXGroup *)group didFetchMemberList:(NSArray *)membersList error:(JXError *)error;

/*!
 @method
 @brief 获取群组信息后的回调
 @discussion
 @param group 群组对象
 @param error 错误信息
 @result
 */
- (void)didFetchGroupInfo:(JXGroup *)group error:(JXError *)error;

/*!
 @method
 @brief 群组列表发生变化的回调
 @discussion
 @param groupList 群组列表
 @result
 */
- (void)didGroupListUpdate:(NSArray *)groupList;

/*!
 @method
 @brief 标题更新的回调
 @discussion
 @param group 群组对象
 @param member 修改标题的群成员对象
 @param error 错误信息
 @result
 */
- (void)groupDidUpdateSubject:(JXGroup *)group
                     byMember:(JXGroupMember *)member
                        error:(JXError *)error;

/*!
 @method
 @brief 昵称更新的回调
 @discussion
 @param group 群组对象
 @param member 修改昵称的群成员对象
 @param error 错误信息
 @result
 */
- (void)groupDidUpdateNickname:(JXGroup *)group
                      byMember:(JXGroupMember *)member
                         error:(JXError *)error;

/*!
 @method
 @brief 收到加入群组的申请 + 申请入群发生错误
 @discussion
 @param groupId         要加入的群组ID
 @param groupname       申请人的用户名
 @param username        申请人的昵称
 @param reason          申请理由
 @param error           错误信息
 @result
 */
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(JXError *)error;

/*!
 @method
 @brief 用户申请加入群组，群主同意后，用户收到回调 + 用户申请入群，群主同意申请发生错误
 @discussion
 @param groupId         申请加入的群组的ID
 @param groupname       申请加入的群组名称
 @param error           错误信息
 @result
 */
- (void)didReceiveAcceptApplyToJoinGroup:(NSString *)groupId
                               groupname:(NSString *)groupname
                                   error:(JXError *)error;

/*!
 @method
 @brief 用户申请加入群组，群主拒绝后，用户收到回调 + 用户申请入群，群主拒绝申请发生错误
 @discussion
 @param groupId         申请加入的群组的ID
 @param groupname       申请加入的群组名称
 @param error           错误信息
 @result
 */
- (void)didReceiveRejcetApplyToJoinGroup:(NSString *)groupId
                               groupname:(NSString *)groupname
                                   error:(JXError *)error;

/*!
 @method
 @brief 群主将用户添加到群黑名单之后回调
 @discussion
 @param groupId         加入黑名单的群组的ID
 @param username        被加入黑名单的用户的昵称
 @param error           错误信息
 @result
 */
- (void)didBlockGoupMember:(NSString *)username inGroup:(NSString *)groupId error:(JXError *)error;

/*!
 @method
 @brief 群主将用户从群黑名单移除之后回调
 @discussion
 @param groupId         加入黑名单的群组的ID
 @param username        被移出黑名单的用户的昵称
 @param error           错误信息
 @result
 */
- (void)didUnblockGoupMember:(NSString *)username
                     inGroup:(NSString *)groupId
                       error:(JXError *)error;

/*!
 @method
 @brief 群主获取群黑名单列表
 @discussion
 @param groupId         群组的ID
 @param membersList     被获取到的黑名单成员列表
 @param error           错误信息
 @result
 */
- (void)group:(JXGroup *)group
        didFetchedBlockMemberList:(NSArray *)membersList
                            error:(JXError *)error;

/*!
 @method
 @brief 邀请成员失败的回调
 @discussion
 @param groupI          群组
 @param username        邀请失败的用户
 @param reason          失败原因
 @result
 */
- (void)group:(JXGroup *)group didFailedInviteMember:(NSString *)username reason:(JXError *)error;

@end
