//
//  JXChatViewController+Toolbar.h
//

#import "JXChatViewController.h"

@interface JXChatViewController (Toolbar)<JXMessageToolbarDelegate, UIImagePickerControllerDelegate,
                                          UINavigationControllerDelegate>

@property(nonatomic, strong, readonly) JXVoiceMessageRecorder *voiceRecorder;

- (void)toolBarAddPhotoItemWithTitle:(NSString *)title andImage:(UIImage *)image;

- (void)toolbarAddCameraItemWithTitle:(NSString *)title andImage:(UIImage *)image;

- (void)toolbarAddVideoItemWithTitle:(NSString *)title andImage:(UIImage *)image;

- (void)toolbarAddAudioCallItemWithTitle:(NSString *)title andImage:(UIImage *)image;

- (void)toolbarAddVideoCallItemWithTitle:(NSString *)title andImage:(UIImage *)image;

- (void)toolbarAddLocationItemWithTitle:(NSString *)title andImage:(UIImage *)image;

/**
 *  自定义添加功能
 *
 *  @param title  功能标题
 *  @param image  功能item图片
 *  @param action 功能实现
 */
- (void)toolbarAddCustomItemWithTitle:(NSString *)title
                             andImage:(UIImage *)image
                            andAction:(void (^)(NSInteger index))action;

/**
 *  自定义删除功能
 *
 *  @param title  功能标题
 *  @param image  功能item图片
 *  @param action 功能实现
 */
- (void)toolbarDeleteCustomItemWithTitle:(NSString *)title
                                andImage:(UIImage *)image
                               andAction:(void (^)(NSInteger index))action;

/**
 *  隐藏toolbar
 */
- (void)hideToolbar:(BOOL)hidden;

@end
