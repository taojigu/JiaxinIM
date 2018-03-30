//
// JXFacialView.h
//

#import <UIKit/UIKit.h>


@class JXEmotionPackage;

@protocol JXFacialViewDelegate

@optional
- (void)selectedFacialView:(NSString *)str;
- (void)deleteSelected:(NSString *)str;
- (void)sendFace;
- (void)sendFace:(NSString *)str;

@end

@class EaseEmotionManager;

@interface JXFacialView : UIView

@property(nonatomic) id<JXFacialViewDelegate> delegate;

@property(nonatomic, readonly) NSArray *faces;


/**
 行数,默认为3
 */
@property(nonatomic, assign) NSInteger emotionRow;


/**
 列数,默认为7
 */
@property(nonatomic, assign) NSInteger emotionCol;

- (void)loadFacialView:(JXEmotionPackage *)emotionPackage size:(CGSize)size;

//-(void)loadFacialView:(int)page size:(CGSize)size;

@end
