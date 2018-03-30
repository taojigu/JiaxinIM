//
//  UINavigationController+JXCategory.h
//  JXTest
//
//  Created by 刘佳 on 2017/12/19.
//  Copyright © 2017年 deepin do. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (JXCategory) <UINavigationBarDelegate>

@property(nonatomic, copy) void (^popItemAction)(UINavigationController *navC);

@end
