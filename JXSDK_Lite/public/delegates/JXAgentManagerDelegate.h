//
//  JXMCSManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXWorkgroup.h"

@class JXMcsSession;
@class JXMcsAgent;
@class JXMessage;

@protocol JXAgentManagerDelegate<JXBaseDelegate>

@optional

- (void)didQueueSessionsUpdate;

- (void)didVisitorSessionsUpdate;

- (void)didAgentListUpdate:(NSArray *)agentList;

- (void)didAgentStatusUpdate:(JXMcsAgent *)agent;

- (void)didEnterWorkgroup:(JXWorkgroup *)workgroup withError:(JXError *)error;

- (void)didRecallSessionDone:(JXMcsSession *)session withError:(JXError *)error;

- (void)didSessionTransferDone:(JXMcsSession *)session withError:(JXError *)error;

- (void)didSessionStatusUpdate:(JXMcsSession *)session;

/**
 *  lj: 坐席接受到访客已评价消息
 */
- (void)didVisitorEvaluated:(JXMessage *)message;

/**
 *  lj: 坐席接收到预知消息
 *
 *  @param message 为空时表示访客取消输入
 */
- (void)didAgentReciveForeSeeMessage:(JXMessage *)message;

/**
 *  lj: 会话被结束
 */
- (void)didSession:(JXMcsSession *)session destoryWithError:(JXError *)error;


/**
 *  lj: 坐席退出讨论组
 */
- (void)didSession:(JXMcsSession *)session memberLeave:(NSString *)nickname;


/**
 *  lj: 呼叫中心外线专家模式设置失败
 */
- (void)didCallCenterExternalLineCallSetFailed;

@end
