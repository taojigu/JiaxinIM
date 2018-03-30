//
//  GTMcsChatConfig.m
//  JXUIKit
//
//  Created by 刘佳 on 2017/12/15.
//  Copyright © 2017年 DY. All rights reserved.
//

#import "JXMcsChatConfig.h"
#import "JXSDKHelper.h"

@implementation JXMcsChatConfig

- (UIImage *)requestCSItemImage {
    if (!_requestCSItemImage) {
        _requestCSItemImage = JXChatImage(@"changeCS");
    }
    return _requestCSItemImage;
}

- (UIImage *)msgBoxItemImage {
    if (!_msgBoxItemImage) {
        _msgBoxItemImage = JXChatImage(@"msgBox");
    }
    return _msgBoxItemImage;
}

- (UIImage *)leaveMsgItemImage {
    if (!_leaveMsgItemImage) {
        _leaveMsgItemImage = JXChatImage(@"leaveMsg");
    }
    return _leaveMsgItemImage;
}

- (UIImage *)terminalCSItemImage {
    if (!_terminalCSItemImage) {
        _terminalCSItemImage = JXChatImage(@"quitChat");
    }
    return _terminalCSItemImage;
}

- (UIImage *)avatorImage {
    if (!_avatorImage) {
        _avatorImage = JXChatImage(@"head_receiver");
    }
    return _avatorImage;
}

- (UIColor *)navTitleColor {
    if (!_navTitleColor) {
        _navTitleColor = JXColorWithRGB(100, 100, 100);
    }
    return _navTitleColor;
}

- (UIFont *)navFont {
    if (!_navFont) {
        _navFont = [UIFont boldSystemFontOfSize:18.0];
    }
    return _navFont;
}

+ (instancetype)defaultConfig {
    JXMcsChatConfig *instance = [[JXMcsChatConfig alloc] init];
    instance.showMsgBoxItem = YES;
    return instance;
}

@end
