//
//  JXRestUtil.h
//  JXSDK
//
//  Copyright (c) 2015年 DY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JXRestCallback)(id response, NSInteger status, NSError *error);

@interface JXRestUtil : NSObject

+ (NSURL *)getRestURLWithAppName:(NSString *)appName andApi:(NSString *)api;

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)url;

+ (void)sendSyncRequest:(NSMutableURLRequest *)request withRes:(id *)res error:(NSError **)error;

+ (void)sendRequest:(NSMutableURLRequest *)request withCallback:(JXRestCallback)callback;

@end
