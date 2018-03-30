//
//  JXVideoRecordViewController.h
//  JXUIKit
//
//  Created by raymond on 16/11/11.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXBaseViewController.h"
#import "JXMovieRecorder.h"

@interface JXVideoRecordViewController : JXBaseViewController

@property(nonatomic, copy) void (^completeAction)(NSDictionary *info);

@end
