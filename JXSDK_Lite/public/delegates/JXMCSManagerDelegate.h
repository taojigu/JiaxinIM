//
//  JXMCSManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXBaseDelegate.h"
#import "JXWorkgroup.h"
#import "JXMcsEvaluation.h"

@protocol JXMCSManagerDelegate<JXBaseDelegate>

@optional

- (void)didServiceStatusUpdated:(JXWorkgroup *)workgroup;

- (void)didService:(JXWorkgroup *)workgroup positionChanged:(NSInteger)position;

- (void)didServiceEnd:(JXWorkgroup *)workgroup withError:(JXError *)error;

- (void)didReceiveEvaluationRequest:(JXWorkgroup *)workgroup;

- (void)didReceiveAgentLeaveMessage:(NSDictionary *)info;

@end
