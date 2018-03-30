//
//  JXAppConfig+Extends.m
//  JXUIKit
//
//  Created by raymond on 16/7/6.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXAppConfig+Extends.h"
#import <objc/runtime.h>

#define JXAppConfigAgentIconImage @"JXAppConfigAgentIconImage"

@implementation JXAppConfig (Extends)

- (UIImage *)agentIconImage {
    if (objc_getAssociatedObject(self, JXAppConfigAgentIconImage)) {
        return objc_getAssociatedObject(self, JXAppConfigAgentIconImage);
    }
    if (self.agentHeadImg) {
        NSString *agentHeadImg =
                [self.agentHeadImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:agentHeadImg]];
        UIImage *iconImage = [UIImage imageWithData:data];
        objc_setAssociatedObject(self, JXAppConfigAgentIconImage, iconImage,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return iconImage;
    }
    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"agentHeadImg"]) {
        objc_setAssociatedObject(self, JXAppConfigAgentIconImage, nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [super setValue:value forKey:key];
}

@end
