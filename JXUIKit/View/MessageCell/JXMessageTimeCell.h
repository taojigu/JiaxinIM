//
//  JXMessageTimeCell.h
//

#import <UIKit/UIKit.h>

@interface JXMessageTimeCell : UITableViewCell

@property(nonatomic) NSString *title;

// default [UIFont systemFontOfSize:12]
@property(nonatomic) UIFont *titleLabelFont UI_APPEARANCE_SELECTOR;
// default [UIColor whiteColor]
@property(nonatomic) UIColor *titleLabelColor UI_APPEARANCE_SELECTOR;
// default [UIColor colorWithWhite:0.8 alpha:1]
@property (nonatomic, strong) UIColor *titleLabelBkgColor UI_APPEARANCE_SELECTOR;
// default [UIColor colorWithWhite:0.8 alpha:1]
@property (nonatomic, assign) CGFloat titleLabelCornerRadious UI_APPEARANCE_SELECTOR;

+ (NSString *)cellIdentifier;

@end
