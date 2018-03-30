//
//  NSTimer+Category.h
//  JXTimerTest
//
//  Created by raymond on 16/4/21.
//  Copyright © 2016年 raymond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Category)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)(void))block
                                       repeats:(BOOL)repeats;

@end
