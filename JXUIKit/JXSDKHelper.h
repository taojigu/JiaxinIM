//
//  JXSDKHelper.h
//

#import "JXLocalizeHelper.h"
#import "JXMacros.h"

#import "JXHUD.h"
#import "JXReminder.h"

#import "UIView+Extends.h"
#import "UIImage+Extensions.h"
#import "UITableView+Extends.h"
#import "NSDate+Extends.h"
#import "NSString+Extends.h"
#import "NSTimer+Category.h"

#import "JXConversation+Extends.h"
#import "JXError+LocalDescription.h"
#import "JXMessage+Extends.h"

#ifdef JX_AGENT
#import "JXAgentClient+Helper.h"
#ifndef sClient
#define sClient [JXAgentClient sharedInstance]
#endif
#else
#import "JXIMClient+Helper.h"
#ifndef sClient
#define sClient [JXIMClient sharedInstance]
#endif
#endif
