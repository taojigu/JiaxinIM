//
// JXFaceView.h
//

#import <UIKit/UIKit.h>

#import "JXFacialView.h"

@protocol JXFaceDelegate

@required
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;
- (void)sendFace;
- (void)sendFaceWithEmotion:(NSString *)emotion;

@end

@interface JXFaceView : UIView<JXFacialViewDelegate>

@property(nonatomic, assign) id<JXFaceDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

- (void)setEmotionPackages:(NSArray *)emotionPackages;

@end
