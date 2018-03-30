//
//  JXManagerDelegate.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXAgentManagerDelegate.h"
#import "JXCallManagerDelegate.h"
#import "JXChatManagerDelegate.h"
#import "JXChatroomManagerDelegate.h"
#import "JXConferenceManagerDelegate.h"
#import "JXContactManagerDelegate.h"
#import "JXGroupManagerDelegate.h"
#import "JXLoginManagerDelegate.h"
#import "JXMCSManagerDelegate.h"

@protocol JXClientDelegate <JXLoginManagerDelegate, JXGroupManagerDelegate,
    JXChatManagerDelegate, JXContactManagerDelegate, JXCallManagerDelegate,
    JXMCSManagerDelegate, JXChatroomManagerDelegate, JXAgentManagerDelegate,
    JXConferenceManagerDelegate>

@end
