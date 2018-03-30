//
//  JXVideoView.h
//  JXSDK
//
//  Copyright (c) jiaxincloud.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JXVideoView;
@protocol JXVideoViewDelegate

/*!
 @method
 @brief 视频画面改变的回调
 @param videoView     视频画面
 @param size          尺寸
 @discussion
 @result
 */
- (void)videoView:(JXVideoView*)videoView didChangeVideoSize:(CGSize)size;

@end

@interface JXVideoView : UIView

/*!
 @class
 @brief JXVideoView的代理
 */
@property(nonatomic, weak) id<JXVideoViewDelegate> delegate;

@end
