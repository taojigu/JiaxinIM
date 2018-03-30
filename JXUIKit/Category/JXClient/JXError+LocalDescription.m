//
//  JXError+LocalDescription.m
//

#import "JXError+LocalDescription.h"
#import "JXLocalizeHelper.h"

@implementation JXError (LocalDescription)

- (NSString *)getLocalDescription {
    NSString *desctipStr = self.description;
    switch (self.errorCode) {
        case JXErrorTypeSuccess:
            desctipStr = JXUIString(@"success");
            break;
        case JXErrorTypeOther:
            desctipStr = JXUIString(@"unkonw error");
            break;

        case JXErrorTypeNetworkDisconnected:
            desctipStr = JXUIString(@"network error");
            break;
        case JXErrorTypeNetworkTimeout:
            desctipStr = JXUIString(@"network timeout");
            break;
        case JXErrorTypeSDKInternal:
            desctipStr = JXUIString(@"sdk internal error");
            break;
        case JXErrorTypeLoginConflict:
            desctipStr = JXUIString(@"login in other device");
            break;
        case JXErrorTypeServerInternal:
            desctipStr = JXUIString(@"server internal error");
            break;
        case JXErrorTypePasswordModified:
            desctipStr = JXUIString(@"password changed");
            break;
        case JXErrorTypeUserRemoved:
            desctipStr = JXUIString(@"user removed");
            break;
        case JXErrorTypeUsernameExist:
            desctipStr = JXUIString(@"username existed");
            break;
        case JXErrorTypeUsernameIllegalCharacter:
            desctipStr = JXUIString(@"username error");
            break;
        case JXErrorTypeUsernameLengthInvalid:
            desctipStr = JXUIString(@"username length error");
            break;
        case JXErrorTypeRequestParameterInvalid:
            desctipStr = JXUIString(@"param error");
            break;
        case JXErrorTypeNotRegisterSDK:
            desctipStr = JXUIString(@"sdk not registered");
            break;
        case JXErrorTypeRegisterSDKFailed:
            desctipStr = JXUIString(@"sdk register failed");
            break;
        case JXErrorTypeAppnameInvalid:
            desctipStr = JXUIString(@"appkey error");
            break;

        case JXErrorTypeMcsAccountDisabled:
            desctipStr = JXUIString(@"agent account limit");
            break;
        case JXErrorTypeMcsNotInService:
            desctipStr = JXUIString(@"no service");
            break;
        case JXErrorTypeMcsSkillsIdNotExist:
            desctipStr = JXUIString(@"workgroup not exist");
            break;
        case JXErrorTypeMcsHasEvaluation:
            desctipStr = JXUIString(@"already evaluated");
            break;
        case JXErrorTypeMcsInvalidAccess:
            desctipStr = JXUIString(@"invalid access");
            break;
            
            // 坐席相关
        case JXErrorTypeLoginInvalidUsernameOrPassword:
            desctipStr = @"密码错误";
            break;
        case JXErrorTypeMcsTransferFailedReasonBusy:
            desctipStr = @"坐席繁忙，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonOffline:
            desctipStr = @"坐席离线，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonReject:
            desctipStr = @"坐席拒绝，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonWorkGroupBusy:
            desctipStr = @"技能组繁忙，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonWorkGroupEmpty:
            desctipStr = @"技能组无坐席，转接失败";
            break;
        case JXErrorTypeMcsTransferFailedReasonUnknow:
            desctipStr = @"未知错误，转接失败";
            break;
        case JXErrorTypeMcsRecallReject:
            desctipStr = @"用户拒接，回呼失败";
            break;
        case JXErrorTypeMcsUserOfflineCantRecall:
        case JXErrorTypeMcsRecallFailedReasonOffline:
            desctipStr = @"用户离线，回呼失败";
            break;
        case JXErrorTypeMcsRecallFailedReasonBusy:
            desctipStr = @"用户繁忙，回呼失败";
            break;
        case JXErrorTypeMcsRecallFailedReasonQueuing:
            desctipStr = @"用户排队中，回呼失败";
            break;
        case JXErrorTypeMcsRecallFailedReasonUnknow:
            desctipStr = @"回呼失败";
            break;
        default:
            desctipStr = JXUIString(@"unknow error");
            break;
    }
    return desctipStr;
}

@end
