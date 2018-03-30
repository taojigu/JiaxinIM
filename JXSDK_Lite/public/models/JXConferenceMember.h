//
//  JXConferenceMember.h
//  JXSDK
//
//  Created by YuSong.Yan on 16/3/16.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXBaseModel.h"

@interface JXConferenceMember : JXBaseModel
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) BOOL isJoined;

- (instancetype)initWithUserName:(NSString *)userName isJoinedIn:(BOOL)isJoinedIn;

@end
