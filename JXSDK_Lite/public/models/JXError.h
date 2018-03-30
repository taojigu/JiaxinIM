//
//  JXError.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JXEnumDefs.h"

@interface JXError : NSObject

/*!
 @class
 @brief 错误的类型
 */
@property(nonatomic, assign) JXErrorType errorCode;

/*!
 @class
 @brief 错误信息的描述
 */
@property(nonatomic, copy) NSString *errorDescription;

/*!
 @method
 @brief 类方法初始化一个错误对象
 @discussion
 @param errorCode     错误类型
 @param description   错误信息描述
 @result JXError      错误对象
 */
+ (JXError *)errorWithCode:(JXErrorType)errorCode andDescription:(NSString *)description;

/*!
 @method
 @brief 类方法初始化一个错误对象
 @discussion
 @param error     错误信息
 @result JXError  错误对象
 */
+ (JXError *)errorWithNSError:(NSError *)error;

@end
