//
//  IMToolBarOptionView.h
//

#import <UIKit/UIKit.h>

@interface JXToolBarOptionItem : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) UIImage *image;

@end

@interface JXToolBarMoreView : UIView

@property (nonatomic, copy) void (^action)(NSInteger index);

- (instancetype)initWithOptionItems:(NSMutableArray *)items;

/**
 *  添加自定义item
 *
 *  @param title  item标题
 *  @param image  item图片
 *  @param action item点击事件
 */
- (void)addItemWithTitle:(NSString *)title
                andImage:(UIImage *)image
               andAction:(void (^)(NSInteger index))action;

- (void)deleteItemWithTitle:(NSString *)title
                andImage:(UIImage *)image
               andAction:(void (^)(NSInteger index))action;
/**
 *  计算moriew的大小
 *
 *  @return moreview的大小
 */
- (CGSize)intrinsicContentSize;

@end
