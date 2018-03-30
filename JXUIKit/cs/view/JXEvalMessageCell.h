//
//  JXEvalMessageCell.h
//

#import "JXCommonMessageCell.h"

//#define JXEvalMessageType 100
#define JXEvalButtonHeight 30

// 自定义聊天气泡 此处为用户收到评价请求时显示的气泡

@interface JXEvalMessageCell : JXCommonMessageCell

@property(nonatomic) UIButton *cellButton;

@end

@interface JXBubbleView (Eval)

- (void)setupEvalBubbleView;

- (void)updateRequestMargin:(UIEdgeInsets)margin;

@end
