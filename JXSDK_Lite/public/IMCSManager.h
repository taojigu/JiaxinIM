//
//  IMCSManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "IBaseManager.h"
#import "JXMcsEvaluation.h"
#import "JXWorkgroup.h"

@protocol IMCSManager<IBaseManager>

/**
 更新访客信息
 */
- (void)updateVisitorInfo:(NSDictionary *)info;

/**
 当前技能组
 */
- (JXWorkgroup *)activeService;


/**
 查询快速提问问题
 */
- (void)fetchQuickQuestionsWithCallback:(void (^)(id responseObject, JXError *error))callback;


/**
 查询快速提问问题（同步）
 */
- (NSArray *)fetchQuickQuestionsSync;


/**
 查找技能组列表
 */
- (void)fetchCustomServicesWithCallback:(void (^)(id responseObject, JXError *error))callback;

/**
 查找技能组列表（同步）
 */
- (NSArray *)fetchCustomServicesSync;


/**
 查找满意度评价配置

 @param callback
 */
- (void)fetchEvaluationConfigWithCallback:(void (^)(id res, JXError *error))callback;
- (JXMcsEvaluation *)fetchEvaluationConfigSync;

/**
 查找历史回话消息

 @param conversation 当前绘画对象
 @param limit 消息条数
 @param message 最后一条消息
 @param callBack
 */
- (void)fetchChatLogForConversation:(JXConversation *)conversation
                          withLimit:(NSInteger)limit
                        fromMessage:(JXMessage *)message
                       withCallBack:(void (^)(NSArray *historyMessages, JXError *error))callBack;

/**
 请求服务

 @param service 技能组
 */
- (void)requestCustomerService:(JXWorkgroup *)service;
- (void)requestCustomerService:(JXWorkgroup *)service andExtendData:(NSString *)extendData;


/**
 转人工客服
 */
- (void)transferCustomerService;
- (void)transferCustomerServiceWithExtendData:(NSString *)extendData;


/**
 取消等待
 */
- (void)cancelWait;


/**
 退去会话
 */
- (void)leaveService;

/**
 评价服务

 @param service 技能组
 @param score 分数
 @param callback
 */
- (void)evaluateService:(JXWorkgroup *)service
               andScore:(NSInteger)score
            andCallback:(void (^)(JXError *error))callback;


/**
 获取离线消息URL

 @param workgroup 技能组
 @return
 */
- (NSURL *)leaveMessageURL:(JXWorkgroup *)workgroup;

@end
