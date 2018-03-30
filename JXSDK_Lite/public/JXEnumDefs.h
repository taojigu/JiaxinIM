//
//  JXEnumDefs.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#ifndef JXSDK_JXEnumDefs_h
#define JXSDK_JXEnumDefs_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JXMessageType) {
    JXMessageTypeEmpty = 0,
    JXMessageTypeText,
    JXMessageTypeImage,
    JXMessageTypeAudio,
    JXMessageTypeVideo,
    JXMessageTypeLocation,
    JXMessageTypeVcard,
    JXMessageTypeFile,
    // other
    JXMessageTypeRichText,
    JXMessageTypePicText,
    JXMessageTypeVoiceCall,
    JXMessageTypeVideoCall,
    JXMessageTypeEvaluation,
    JXMessageTypeForeseeComposing,
    JXMessageTypeForeseeRecording,
    JXMessageTypeTips,
};

//聊天类型
typedef NS_ENUM(NSInteger, JXChatType) {
    JXChatTypeChat = 1,
    JXChatTypeGroup,    //群聊
    JXChatTypeRoom,     //聊天室
    JXChatTypeCS,       //客服
};

//消息方向
typedef NS_ENUM(NSInteger, JXMessageDirection) {
    JXMessageDirectionSend = 1,    //发送
    JXMessageDirectionReceive,     //接收
};

//消息状态
typedef NS_ENUM(NSInteger, JXMessageStatus) {
    JXMessageStatusNone,
    JXMessageStatusSending,        //发送中
    JXMessageStatusSend,           //已达服务端
    JXMessageStatusDelivered,      //已达接收者
    JXMessageStatusRead,           //已读
    JXMessageStatusBurned,         //已毁
    JXMessageStatusNew,            //新消息
    JXMessageStatusDownloading,    //小附件自动下载中
    JXMessageStatusDownload,       //附件下载完成
    JXMessageStatusReject,
    JXMessageStatusFailure,        //发送失败
    JXMessageStatusError,
};

//群消息策略
typedef NS_ENUM(NSInteger, JXGroupPolicy) {
    //
    JXGroupPolicyReceiveAndNotice,    //接收并提醒
    JXGroupPolicyReceiveOnly,         //仅接收
    JXGroupPolicyReject               //不接收
};

typedef NS_ENUM(NSInteger, JXGroupRole) {
    //
    JXGroupRoleAdmin,     //群主
    JXGroupRoleMember,    //群成员
    JXGroupRoleBlock      //群黑名单成员
};

typedef NS_ENUM(NSInteger, JXErrorType) {
    //
    JXErrorTypeSuccess = 0,
    JXErrorTypeOther = 9999,

    //网络与SDK
    JXErrorTypeNetworkDisconnected = 1001,
    JXErrorTypeNetworkTimeout,
    JXErrorTypeSDKInternal,
    JXErrorTypeLoginConflict,
    JXErrorTypeServerInternal,
    JXErrorTypePasswordModified,
    JXErrorTypeUserRemoved,
    JXErrorTypeUsernameExist,
    JXErrorTypeUsernameIllegalCharacter,
    JXErrorTypeUsernameLengthInvalid,
    JXErrorTypeRequestParameterInvalid,
    JXErrorTypeNotRegisterSDK,
    JXErrorTypeRegisterSDKFailed,
    JXErrorTypeAppnameInvalid,

    //登录
    JXErrorTypeLoginUserNameEmpty = 1100,
    JXErrorTypeLoginPasswordEmpty,
    JXErrorTypeLoginUserNameNotExist,
    JXErrorTypeLoginPasswordError,
    JXErrorTypeLoginInvalidUsernameOrPassword,
    JXErrorTypeLoginEmailEmpty,
    JXErrorTypeAgentOnlineLimited,

    //联系人
    JXErrorTypeContactAddFriendConflict = 1200,
    JXErrorTypeContactNotYourFriend,
    JXErrorTypeBacklistConflict,
    JXErrorTypeContactInfoMissing,
    JXErrorTypeBlockContactFailed,

    //消息
    JXErrorTypeMessageTypeNotDefined = 1300,
    JXErrorTypeMessageChatTypeNotDefined,
    JXErrorTypeMessageChatTypeNotAllowed,
    JXErrorTypeMessageSendFailed,    // add 消息发送失败
    JXErrorTypeMessageObjectMismatch,
    JXErrorTypeMessageTitleEmpty,
    JXErrorTypeMessageTextEmpty,
    JXErrorTypeMessageFileNotExist,
    JXErrorTypeMessageFileEmpty,
    JXErrorTypeMessageFileTypeMismatch,
    JXErrorTypeMessageFileSizeExceeded,
    JXErrorTypeMessageRecordDurationExceeded,
    JXErrorTypeMessageThumbNotExist,
    JXErrorTypeMessageThumbEmpty,
    JXErrorTypeMessagethumbFailed,
    JXErrorTypeConversationNotFound,
    JXErrorTypeMessageUploadFailed,
    JXErrorTypeMessageDownloadFailed,
    JXErrorTypeMessageReceiverRejected,
    JXErrorTypeMessageNotAllowed,

    //群聊
    JXErrorTypeGroupChatForbidden = 1400,
    JXErrorTypeGroupChatUserNotExistInRoom,
    JXErrorTypeGroupChatGetInfoFailed,    // add 获取群信息失败
    JXErrorTypeGroupChatSubjectIllegalCharacter,    // add 群成名包含非法字符
    JXErrorTypeGroupChatNicknameIllegalCharacter,    // add 群昵称包含非法字符
    JXErrorTypeGroupChatSubjectForbidden,    // add 禁止修改群名称
    JXErrorTypeGroupChatSameNickname,
    JXErrorTypeGroupChatSubjectNoChange,  // 群聊主题没有改变
    JXErrorTypeGroupChatPrivateGroupBanApply,
    JXErrorTypeGroupChatRoomNotExist,
    JXErrorTypeGroupChatBlockOperationFailed,
    JXErrorTypeGroupChatAccessPermissionOwner,
    JXErrorTypeGroupChatCreatFailed,
    JXErrorTypeGroupChatInviteBlockMember, // 邀请的成员为黑名单成员
    //通话
    JXErrorTypeCallCalleeOffline = 1600,
    JXErrorTypeCallCalleeBusy,
    JXErrorTypeCallCalleeDeclined = 1610,
    JXErrorTypeCallHangup,
    JXErrorTypeCallCallerCancel,
    JXErrorTypeCallTimeout,
    JXErrorTypeCallDisconnection,
    JXErrorTypeConfCreateFailed,

    //移动客服
    JXErrorTypeMcsDestorySessionSuccess = 1700,
    JXErrorTypeMcsCancelWait,
    JXErrorTypeMcsNotInService,
    JXErrorTypeMcsSkillsIdNotExist,
    JXErrorTypeMcsHasEvaluation,
    JXErrorTypeMcsAccountDisabled,

    JXErrorTypeMcsInvalidAccess = 1800,
    JXErrorTypeMcsLeaveQueue,
    JXErrorTypeMcsRequestTimeout,
    JXErrorTypeMcsEvaluateFailed,
    JXErrorTypeMcsFetchQuickQuestionFailed,
    JXErrorTypeMcsGetWorkgroupFailed,
    JXErrorTypeMcsSkillsIdEmpty,
    JXErrorTypeMcsUserOfflineCantRecall,
    JXErrorTypeMcsUserInitSuccess,
    JXErrorTypeMcsEnterGroupInOther,
    JXErrorTypeMcsRecallReject,
    JXErrorTypeMcsChatTimeout, // 访客或坐席会话超时
    JXErrorTypeMcsChatAutoClose, // 会话自动结束
    JXErrorTypeMcsSessionGrab, // 会话被抢接
    JXErrorTypeMcsSessionKick, // 多客服群聊被踢

    JXErrorTypeMcsCustmerInfoNil,
    JXErrorTypeMcsTransferFailedReasonOffline,
    JXErrorTypeMcsTransferFailedReasonUnknow,
    JXErrorTypeMcsTransferFailedReasonWorkGroupEmpty,
    JXErrorTypeMcsTransferFailedReasonWorkGroupBusy,

    JXErrorTypeMcsRecallFailedReasonOffline,
    JXErrorTypeMcsRecallFailedReasonBusy,
    JXErrorTypeMcsRecallFailedReasonBusyAndAnentOffline,
    JXErrorTypeMcsRecallFailedReasonUnknow,
    JXErrorTypeMcsRecallFailedReasonQueuing,

    JXErrorTypeMcsTransferFailedReasonBusy,
    JXErrorTypeMcsTransferFailedReasonReject,

    JXErrorTypeMcsTagIsNil,
    JXErrorTypeMcsRemarkIsTooLong,

    JXErrorTypeMcsNotInServiceWithRobot = 1822,
    JXErrorTypeMcsOverOnlineCustomerService,
    JXErrorTypeMcsNotInServiceWithLeaveRobot,
    JXErrorTypeMcsAgentOffWork, // 客服已下班
    JXErrorTypeMcsJoinQueueForbidden, // 排队人数达上限

    JXErrorTypeChatroomForbidden = 1900,
    JXErrorTypeChatroomNotAllowed,

    JXErrorTypeMcsVistorMobileExist, // 保存访客信息时手机号码重复
};

//群消息策略
typedef NS_ENUM(NSInteger, JXGroupLeaveReason) {
    //
    JXGroupLeaveReasonBeRemoved,    //被群主移除
    JXGroupLeaveReasonLeave,        //用户主动退出群
    JXGroupLeaveReasonDestoryed     //群解散
};

//群成员变化类型
typedef NS_ENUM(NSInteger, JXGroupMemberChangeType) {
    //
    JXGroupMemberChangeTypeJoin,     //有人进群
    JXGroupMemberChangeTypeLeave,    //有人退群
    JXGroupMemberChangeTypeKick,
};

typedef NS_ENUM(NSInteger, JXConnectionType) {
    //
    JXConnectionTypeUnknown,    //未知网络
    JXConnectionTypeNone,       //没有网络
    JXConnectionTypeWWAN,       //蜂窝网络
    JXConnectionTypeWiFi        // Wifi
};

typedef NS_ENUM(NSInteger, JXCallType) {
    //
    JXCallTypeAudio,
    JXCallTypeVideo,
    JXCallTypeAudioConf,
    JXCallTypeVideoConf,
};

typedef NS_ENUM(NSInteger, JXMCSUserStatus) {
    //
    JXMCSUserStatusNone,
    JXMCSUserStatusPending,
    JXMCSUserStatusInRobot,
    JXMCSUserStatusWaiting,
    JXMCSUserStatusAgentOffline, // 坐席离线
    JXMCSUserStatusInService,
    JXMCSUserStatusInRecall,
    JXMCSUserStatusEnd,
    JXMCSUserStatusCloseForwardly, // 访客主动结束会话
};

#endif
