//
//  JXActionView.h
//

#import <UIKit/UIKit.h>

@protocol JXActionViewDelegate<NSObject>

- (void)didSelectedItem:(NSTextCheckingResult *)result;

@end

@interface JXActionView : UIView<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, strong) UITableView *mainTableView;
@property(nonatomic, strong) UIButton *coverBtn;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, weak) id<JXActionViewDelegate> delegate;

@end
