//
//  JXAppConfig.h
//  JXSDK
//
//  Created by raymond on 16/7/5.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXAppConfig : NSObject

+ (instancetype)sharedInstance;

/**
 *  更新开发者中心配置
 */
+ (void)updateConfig;

/**
 * 企业id
 */
@property(nonatomic, copy, readonly) NSString *enterpriseId;

/**
 * 企业建群的最大数量
 */
@property(nonatomic, assign, readonly) NSInteger maxRoomNum;

/**
 * 群成员的最大数量
 */
@property(nonatomic, assign, readonly) NSInteger maxRoomUsersNum;

/**
 * 接待方式设置,0：人工客服优先;1：机器人客服优先（默认）
 */
@property(nonatomic, assign, readonly) BOOL agentAccessType;

/**
 * 是否开启满意度调查通知,1：开启（默认）;0不开启
 */
@property(nonatomic, assign, readonly) BOOL satisfyNotifyFlag;

/**
 * 是否允许使用机器人，1：开启（默认）;0不开启
 */
@property(nonatomic, assign, readonly) BOOL robotFlag;

/**
 * 当前资金，通过充值、扣费改变该值
 */
@property(nonatomic, assign, readonly) NSInteger currentFund;

/**
 * 支付模式，B：预付费；A：后付费
 */
@property(nonatomic, copy, readonly) NSString *payMode;

/**
 * 满意度标题
 */
@property(nonatomic, copy, readonly) NSString *satisfyInvitation;

/**
 * 是否可以上传附件 1可以，0不可以
 */
@property(nonatomic, assign, readonly) BOOL orderUploadFile;

/**
 * 是否可以给关闭的工单添加备注 1可以，0不可以
 */
@property(nonatomic, assign, readonly) BOOL orderEditClosed;

/**
 * 是否可以开启工单关联查询 1可以，0不可以
 */
@property(nonatomic, assign, readonly) BOOL orderExtQueryFlag;

/**
 * 离开是否需要申请 0表示不需要 1表示需要
 */
@property(nonatomic, assign, readonly) BOOL applyDepart;

/**
 * 是否忽略客服最大接待上限限制 0表示不忽略 1表示忽略
 */
@property(nonatomic, assign, readonly) BOOL ignoreTransferLimit;

/**
 * 坐席不在线提示消息
 */
@property(nonatomic, copy, readonly) NSString *agentLeftTip;

/**
 * 超时时间间隔(秒)
 */
@property(nonatomic, assign, readonly) NSTimeInterval timeOutInterval;

/**
 * 满意度调查结束语
 */
@property(nonatomic, copy, readonly) NSString *satisfyThanks;

/**
 * 坐席接单阀值
 */
@property(nonatomic, assign, readonly) NSInteger orderAgentLimit;

/**
 * 工单超时时间
 */
@property(nonatomic, assign, readonly) NSInteger orderOverTime;

/**
 * 工单是否可以离线派单
 */
@property(nonatomic, assign, readonly) BOOL orderOffLineEnable;


/**
 * 工单上传附件大小阈值
 */
@property(nonatomic, assign, readonly) NSInteger orderAttachSize;

/**
 * 是否开启超时提醒统计
 */
@property(nonatomic, assign, readonly) BOOL timeOutNotifyFlag;

/**
 * 语音时长（分钟）
 */
@property(nonatomic, assign, readonly) NSInteger ccDeductType;

/**
 * 访客满意度评价开关 0不开启，1开启
 */
@property(nonatomic, assign, readonly) BOOL visitorSatisfyFlag;

/**
 * 客服头像
 */
@property(nonatomic, copy, readonly) NSString *agentHeadImg;

/** 是否双语种
 * 0表示否
 * 1表示是
 */
@property(nonatomic, assign, readonly) BOOL ccMultLang;

/**
 * 呼叫中心外线模式
 * 0 为没有呼叫中心功能
 * 1 为自由模式
 * 2 为时间模式
 */
@property(nonatomic, assign, readonly) NSInteger ccOutsideMode;

/**
 * 机器人转人工 出错次数
 */
@property(nonatomic, assign, readonly) NSInteger rbtAutoTransferNum;

/**
 * 回访欢迎语
 */
@property(nonatomic, copy, readonly) NSString *recallMsg;

/**
 * 满意度调查通知的类型
 */
@property(nonatomic, assign, readonly) NSInteger satisfyType;

/**
 *  访客结束会话是否评价
 */
@property(nonatomic, assign, readonly) BOOL endSessionSatisfyFlag;

/**
 *  是否开启预知消息
 */
@property (nonatomic, assign, readonly) BOOL prepareFlag;

/**
 *  坐席是否能发送表情
 */
@property(nonatomic, assign, readonly) BOOL agentEmoticonFlag;


/**
 坐席是否能发送语音
 */
@property (nonatomic, assign, readonly) BOOL agentSendAudioFlag;


/**
 坐席是否能发送视频
 */
@property (nonatomic, assign, readonly) BOOL agentSendVideoFlag;

/**
 *  坐席是否能截屏
 */
@property(nonatomic, assign, readonly) BOOL agentScreenCapturingFlag;

/**
 *  坐席端是否能发送文件
 */
@property(nonatomic, assign, readonly) BOOL agentSendFileFlag;

/**
 *  访客是否能发送表情
 */
@property(nonatomic, assign, readonly) BOOL userEmoticonFlag;

/**
 *  访客是否能发送文件
 */
@property(nonatomic, assign, readonly) BOOL userSendFileFlag;

/**
 访客是否能发送语音
 */
@property (nonatomic, assign, readonly) BOOL userSendAudioFlag;

/**
 访客是否能发送视频
 */
@property (nonatomic, assign, readonly) BOOL userSendVideoFlag;

/**
 *  坐席退出登录时是否强制退出会话
 */
@property(nonatomic, assign, readonly) BOOL sessionForceCloseFlag;

/**
 会话是否只能转到技能组
 */
@property(nonatomic, assign, readonly) BOOL imWorkgroupOnly;

/**
 坐席最大接入数
 */
@property(nonatomic, assign) NSInteger agentMaxChats;

@end
