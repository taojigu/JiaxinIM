//
//  UINavigationController+JXCategory.m
//  JXTest
//
//  Created by 刘佳 on 2017/12/19.
//  Copyright © 2017年 deepin do. All rights reserved.
//

#import "UINavigationController+JXCategory.h"
#import <objc/runtime.h>

static void *kPopItemAction = &kPopItemAction;

@implementation UINavigationController (JXCategory)

- (void)setPopItemAction:(void (^)(UINavigationController *))popItemAction {
    objc_setAssociatedObject(self, kPopItemAction, popItemAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (void (^)(UINavigationController *))popItemAction {
    void (^action)(UINavigationController *navC) = objc_getAssociatedObject(self, kPopItemAction);
    return action;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.popItemAction) {
        self.popItemAction(self);
    }
    return YES;
}

@end
