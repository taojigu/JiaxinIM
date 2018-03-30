//
// JXVoiceRecordView.h
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JXRecordViewType) {
    JXRecordViewTypeTouchDown,
    JXRecordViewTypeTouchUpInside,
    JXRecordViewTypeTouchUpOutside,
    JXRecordViewTypeDragInside,
    JXRecordViewTypeDragOutside,
};

@protocol JXRecordViewDelegate <NSObject>

@required
/**
 *  当前录音音量
 */
- (double)currentVolume;

@end

@interface JXRecordView : UIView

@property(nonatomic) NSArray *voiceMessageAnimationImages UI_APPEARANCE_SELECTOR;

@property(nonatomic) NSString *upCancelText UI_APPEARANCE_SELECTOR;

@property(nonatomic) NSString *loosenCancelText UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak) id<JXRecordViewDelegate> delegate;

// 录音按钮按下
- (void)recordButtonTouchDown;
// 手指在录音按钮内部时离开
- (void)recordButtonTouchUpInside;
// 手指在录音按钮外部时离开
- (void)recordButtonTouchUpOutside;
// 手指移动到录音按钮内部
- (void)recordButtonDragInside;
// 手指移动到录音按钮外部
- (void)recordButtonDragOutside;
// 显示录音时间过短
//- (void)showRecordTimeToShortImage;

@end
