//
//  JXCommonMessageCell.h
//

#import "JXMessageCell.h"

@interface JXCommonMessageCell : JXMessageCell

// default 45;
@property(nonatomic) CGFloat avatarSize UI_APPEARANCE_SELECTOR;
// default 22.5;
@property(nonatomic) CGFloat avatarCornerRadius UI_APPEARANCE_SELECTOR;
// default [UIFont systemFontOfSize:10];
@property(nonatomic) UIFont *messageNameFont UI_APPEARANCE_SELECTOR;
// default [UIColor grayColor];
@property(nonatomic) UIColor *messageNameColor UI_APPEARANCE_SELECTOR;
// default 15;
@property(nonatomic) CGFloat messageNameHeight UI_APPEARANCE_SELECTOR;
// default NO;
@property(nonatomic) BOOL messageNameIsHidden UI_APPEARANCE_SELECTOR;

@end
