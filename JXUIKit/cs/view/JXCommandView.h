//
//  JXCommandView.h
//

#import <UIKit/UIKit.h>

@protocol JXRatingViewDelegate <NSObject>

/**
 *  评分改变
 *
 *  @param newRating 新的值
 */
- (void)ratingChanged:(float)newRating;


@end

@interface JXRatingView : UIView {
    float starRating;
    float lastRating;
    
    float height;
    float width;
    float space;
    
    UIImage *unSelectedImage;
    UIImage *halfSelectedImage;
    UIImage *fullSelectedImage;
}

@property (nonatomic,strong) UIImageView *s1;
@property (nonatomic,strong) UIImageView *s2;
@property (nonatomic,strong) UIImageView *s3;
@property (nonatomic,strong) UIImageView *s4;
@property (nonatomic,strong) UIImageView *s5;

@property (nonatomic,weak) id<JXRatingViewDelegate> delegate;

/**
 *  初始化设置未选中图片、半选中图片、全选中图片，以及评分值改变的代理（可以用
 *  Block）实现
 *
 *  @param deselectedName   未选中图片名称
 *  @param halfSelectedName 半选中图片名称
 *  @param fullSelectedName 全选中图片名称
 *  @param delegate          代理
 */
- (void)setImageDeselected:(NSString *)deselectedName
              halfSelected:(NSString *)halfSelectedName
              fullSelected:(NSString *)fullSelectedName
               andDelegate:(id<JXRatingViewDelegate>)delegate;

/**
 *  设置评分值
 *
 *  @param rating 评分值
 */
- (void)displayRating:(float)rating;

/**
 *  获取当前的评分值
 *
 *  @return 评分值
 */
- (float)rating;

/**
 *  是否是指示器，如果是指示器，就不能滑动了，只显示结果，不是指示器的话就能滑动修改值
 *  默认为NO
 */
@property (nonatomic,assign) BOOL isIndicator;

@end


@protocol JXCommandViewDelegate<NSObject>

- (void)didfinishedCommandWithScore:(int)score;

- (void)didSelectedQuestion:(NSString *)question;

@end

@interface JXCommandView : UIView

- (instancetype)initWithTtile:(NSString *)title
                     delegate:(id<JXCommandViewDelegate>)delegate
                        model:(id)model
                        frame:(CGRect)frame;

- (void)showInView:(UIView *)view;

- (void)hideView;

@property(nonatomic, assign) id<JXCommandViewDelegate> delegate;

@end
