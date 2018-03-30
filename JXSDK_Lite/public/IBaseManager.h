//
//  IBaseManager.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import "JXClientDelegate.h"
#import <Foundation/Foundation.h>

@protocol JXClientDelegate;

@protocol IBaseManager<NSObject>

@required

/*!
 @method
 @brief 添加代理
 @discussion
 @param delegate    遵循JXClientDelegate协议的对象
 @result
 */
- (void)addDelegate:(id<JXClientDelegate>)delegate;

/*!
 @method
 @brief 移除代理
 @discussion
 @param delegate    遵循JXClientDelegate协议的对象
 @result
 */
- (void)removeDelegate:(id<JXClientDelegate>)delegate;

@end
