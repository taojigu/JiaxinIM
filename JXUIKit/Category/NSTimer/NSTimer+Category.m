//
//  NSTimer+Category.m
//  JXTimerTest
//
//  Created by raymond on 16/4/21.
//  Copyright © 2016年 raymond. All rights reserved.
//

#import "NSTimer+Category.h"

@implementation NSTimer (Category)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(void (^)(void))block
                                    repeats:(BOOL)repeats {
  return [self scheduledTimerWithTimeInterval:interval
                                       target:self
                                     selector:@selector(blockInvoke:)
                                     userInfo:[block copy]
                                      repeats:repeats];
}

+ (void)blockInvoke:(NSTimer *)timer {
    void (^block)(void) = timer.userInfo;
  if (block) {
    block();
  }
}

@end
