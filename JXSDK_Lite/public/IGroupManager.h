//
//  IGroupChatManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"
#import "JXGroup.h"

@protocol IGroupManager<IBaseManager>

/*!
 @method
 @brief 创建群聊
 @discussion
 @param subject  群名称
 @param description  群描述
 @param members  群成员列表
 @param canChange  是否可以修改群名称 （yes 为可以， no 为不可以）
 @param maxCount  群成员最大的数量
 @param isPublic  是否为公开群 （yes 为是， no 为不是）
 @param canInvite  能否邀请好友 （yes 为能， no 为不能）
 @param isVerifyRequire  是否需要核对请求信息  （yes 为需要， no 为不需要）
 @result
 */
- (void)createGroupChatWithSubject:(NSString *)subject
                       description:(NSString *)description
                           members:(NSArray *)members
                  canChangeSubject:(BOOL)canChange
                          maxCount:(NSInteger)maxCount
                          isPublic:(BOOL)isPublic
                 allowMemberInvite:(BOOL)canInvite
                   isVerifyRequire:(BOOL)isVerifyRequire;

/*!
 @method
 @brief 通过群ID来获得群对象
 @discussion
 @param groupId  群ID （群的唯一标识）
 @result JXGroup 群对象
 */
- (JXGroup *)groupForId:(NSString *)groupId;

/*!
 @method
 @brief 刷新群列表
 @discussion
 */
- (void)updateGroups;

/*!
 @method
 @brief 获得所有的群ID
 @discussion
 @result NSArray 群ID数组
 */
- (NSArray *)groupIds;

/*!
 @method
 @brief 查询公开群
 @discussion
 @param groupInfo  群名称
 @param pageNum  页数
 @param count  群数量
 @param success  没有返回值，参数为responseObject的查询成功的回调
 @param failure  没有返回值，参数为JXError的查询失败回调
 @result
 */
- (void)queryPublicGroupInfo:(NSString *)groupInfo
                  pageNumber:(NSUInteger)pageNum
                       count:(NSUInteger)count
                withCallback:(void (^)(id, JXError *))callback;

/*!
 @method
 @brief 加入公开群
 @discussion
 @param group  群对象
 @result
 */
- (void)joinPublicGroup:(JXGroup *)group;

/*!
 @method
 @brief 通过群ID获得群成员数组
 @discussion
 @param groupId  群ID
 @result
 */
- (void)getGroupMembers:(NSString *)groupId;

/*!
 @method
 @brief 通过群ID获得群信息
 @discussion
 @param groupId  群ID
 @result
 */
- (void)getGroupInfo:(NSString *)groupId;

/*!
 @method
 @brief 设置群标题
 @discussion
 @param subject  群标题
 @param groupId  群ID
 @result
 */
- (void)setSubject:(NSString *)subject forGroup:(NSString *)groupId;

/*!
 @method
 @brief 设置群昵称
 @discussion
 @param nickname  群昵称
 @param groupId  群ID
 @result
 */
- (void)setNickname:(NSString *)nickname forGroup:(NSString *)groupId;

/*!
 @method
 @brief 邀请成员加入群
 @discussion
 @param members  群成员数组
 @param groupId  群ID
 @result
 */
- (void)inviteMembers:(NSArray *)members toGroup:(NSString *)groupId;

/*!
 @method
 @brief 将成员移除群
 @discussion
 @param userName  群成员的用户名
 @param groupId  群ID
 @result
 */
- (void)removeMember:(NSString *)userName fromGroup:(NSString *)groupId;

/*!
 @method
 @brief 退出群组
 @discussion
 @param groupId  群ID
 @result
 */
- (void)quitGroup:(NSString *)groupId;

/*!
 @method
 @brief 销毁群组
 @discussion
 @param groupId  群ID
 @result
 */
- (void)destoryGroup:(NSString *)groupId;

/*!
 @method
 @brief 申请加入群
 @discussion
 @param groupId  群ID
 @param reason   申请原因
 @result
 */
- (void)applyJoinGroup:(JXGroup *)group reason:(NSString *)reason;

/*!
 @method
 @brief 同意加入群的申请
 @discussion
 @param userName  用户名
 @param groupId   群ID
 @result
 */
- (void)agreeApplicationFromBuddy:(NSString *)userName forGroup:(NSString *)groupId;

/*!
 @method
 @brief 不同意加入群的申请
 @discussion
 @param userName  用户名
 @param groupId   群ID
 @param reason    不同意的原因
 @result
 */
- (void)disagreeApplicationFromBuddy:(NSString *)userName
                            forGroup:(NSString *)groupId
                              reason:(NSString *)reason;

/*!
 @method
 @brief 将用户加入群黑名单
 @discussion
 @param userName  加入黑名单的用户名
 @param groupId  群ID
 @result
 */
- (void)blockBuddy:(NSString *)userName forGroup:(NSString *)groupId;

/*!
 @method
 @brief 将用户移出群黑名单
 @discussion
 @param userName  要移除黑名单的用户名
 @param groupId  群ID
 @result
 */
- (void)unblockBuddy:(NSString *)userName forGroup:(NSString *)groupId;

/*!
 @method
 @brief 获取群聊的黑名单
 @discussion 只限群主有该权限
 @param groupId  群ID
 @result
 */
- (void)fetchBlockMembersForGroup:(NSString *)groupId;

@end
