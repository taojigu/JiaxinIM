//
//  JXMessageToolbar.h
//

#import <UIKit/UIKit.h>
#import "JXFaceView.h"
#import "JXMessageTextView.h"
#import "JXVoiceRecordView.h"

#define kTouchToRecord JXUIString(@"press to talk")
#define kTouchToFinish JXUIString(@"release to send")
#define kShowWechatFaceBar @"showWechatFaceBar"

@class JXToolBarMoreView;
@class JXToolBarOptionItem;

@interface JXMessageToolbarItem : NSObject

/**
 *  按钮
 */
@property(nonatomic, readonly) UIButton *button;

/**
 *  点击按钮之后在toolbar下方延伸出的页面
 */
@property(nonatomic) UIView *button2View;

- (instancetype)initWithButton:(UIButton *)button withView:(UIView *)button2View;

@end

@protocol JXMessageToolbarDelegate;

@interface JXMessageToolbar : UIView

@property(weak, nonatomic) id<JXMessageToolbarDelegate> delegate;

@property(nonatomic) UIImage *backgroundImage;

@property(nonatomic, readonly) CGFloat inputViewMaxHeight;

@property(nonatomic, readonly) CGFloat inputViewMinHeight;

@property(nonatomic, readonly) CGFloat horizontalPadding;

@property(nonatomic, readonly) CGFloat verticalPadding;

@property(nonatomic, assign) BOOL isShowWechatBar;

/**
 *  输入框左侧的按钮列表：JXMessageToolbarItem类型
 */
@property(nonatomic) NSArray *inputViewLeftItems;

/**
 *  输入框右侧的按钮列表：JXMessageToolbarItem类型
 */
@property(nonatomic) NSArray *inputViewRightItems;

/**
 *  用于输入文本消息的输入框
 */
@property(nonatomic) JXMessageTextView *inputTextView;

/**
 *  更多的附加页面
 */
@property(nonatomic) UIView *moreView;

/**
 *  表情的附加页面
 */
@property(nonatomic) UIView *faceView;

/**
 *  录音的附加页面
 */
@property(nonatomic) UIView *recordView;


/**
 *  是否隐藏录音切换按钮
 */
@property (nonatomic, assign) BOOL isHiddenRecordBtn;


/**
 *  是否隐藏表情按钮
 */
@property (nonatomic, assign) BOOL isHiddenEmojiBtn;

/**
 *  inputview文本
 */
@property(nonatomic, copy) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  初始化chat bar
 * @param horizontalPadding  default 8
 * @param verticalPadding    default 5
 * @param inputViewMinHeight default 36
 * @param inputViewMaxHeight default 150
 * @param type               default JXMessageToolbarTypeGroup
 */
- (instancetype)initWithFrame:(CGRect)frame
            horizontalPadding:(CGFloat)horizontalPadding
              verticalPadding:(CGFloat)verticalPadding
           inputViewMinHeight:(CGFloat)inputViewMinHeight
           inputViewMaxHeight:(CGFloat)inputViewMaxHeight;

/**
 *  默认高度
 *
 *  @return 默认高度
 */
+ (CGFloat)defaultHeight;

/**
 *  取消触摸录音键
 */
- (void)cancelTouchRecord;

/**
 *  使用默认的更多附加界面 (图片、 拍照、 语音通话、 视频通话、 位置)
 */
- (void)setupDefaultMoreView;

/**
 *  moreView添加发送图片item
 */
- (void)moreViewAddPhotoItemWithTitle:(NSString *)title andImage:(UIImage *)image;

/**
 *  moreView添加拍照功能
 */
- (void)moreViewAddCameraItemWithTitle:(NSString *)title andImage:(UIImage *)image;

/**
 *  moreView添加拍摄视频功能
 */
- (void)moreViewAddVideoItemWithTitle:(NSString *)title andImage:(UIImage *)image;

/**
 *  moreView添加发送位置功能
 */
- (void)moreViewAddLocationItemWithTitle:(NSString *)title andImage:(UIImage *)image;

/**
 *  moreView添加语音通话功能(未实现)
 */
- (void)moreViewAddAudioCallItemWithTitle:(NSString *)title andImage:(UIImage *)image;

/**
 *  moreView添加视频通话功能(未实现)
 */
- (void)moreViewAddVideoCallItemWithTitle:(NSString *)title andImage:(UIImage *)image;

/**
 *  配置自定义item, 如果delegate实现了didselectedCustomItemIndex:方法，action将不会执行;
 */
- (void)moreViewAddCustomItemWithTitle:(NSString *)title
                        andImage:(UIImage *)image
                       andAction:(void (^)(NSInteger index))action;
- (void)moreViewDeleteCustomItemWithTitle:(NSString *)title
                              andImage:(UIImage *)image
                                andAction:(void (^)(NSInteger))action;

@end

@protocol JXMessageToolbarDelegate<NSObject>

@optional

/**
 *  文字输入框开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(JXMessageTextView *)inputTextView;

/**
 *  文字输入框将要开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(JXMessageTextView *)inputTextView;

/**
 *  文字输入框文字改变
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewDidValueChange:(JXMessageTextView *)inputTextView;
/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;

/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 *  @param ext 扩展消息
 */
- (void)didSendText:(NSString *)text withExt:(NSDictionary *)ext;

/**
 *  发送第三方表情，不会添加到文字输入框中
 *
 *  @param faceLocalPath 选中的表情的本地路径
 */
- (void)didSendFace:(NSString *)faceLocalPath;

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView;

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;

/**
 *  松开手指完成录音
 */
- (void)didFinishRecordingVoiceAction:(UIView *)recordView;

/**
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction:(UIView *)recordView;

/**
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction:(UIView *)recordView;

/**
 *  moreView选择照片
 */
- (void)didSelectedPhotoAction:(UIView *)moreView;

/**
 *  moreView选择拍照
 */
- (void)didSelectedCameraAction:(UIView *)moreView;


/**
 *  moreView选择小视频
 */
- (void)didSelectedVideoAction:(UIView *)moreView;

/**
 *  moreView选择语音通话
 */
- (void)didSelectedAudioCallAction:(UIView *)moreView;

/**
 *  moreView选择视频通话
 */
- (void)didSelectedVideoCallAction:(UIView *)moreView;

/**
 *  moreView选择位置
 */
- (void)didselectedLocationAction:(UIView *)moreView;

/**
 *  moreview自定义item方法回调
 */
- (void)didselectedCustomItemIndex:(NSInteger)index;

/**
 *  是否支持语音聊天
 */
- (BOOL)toolBarAllowVoiceChat:(JXMessageToolbar *)toolbar; // Default is YES

/**
 *  是否支持表情聊天
 */
- (BOOL)toolBarAllowEmojiChat:(JXMessageToolbar *)toolbar; // Default is YES

@required
/**
 *  高度变到toHeight
 */
- (void)didChangeFrameToHeight:(CGFloat)toHeight;

/**
 *  录音音量
 *
 *  @return 录音音量
 */
- (double)currentVolume;

@end
