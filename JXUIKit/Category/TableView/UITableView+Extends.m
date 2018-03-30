//
//  UITableView+Extends.m
//

#import "UITableView+Extends.h"
#import "UIView+Extends.h"

@implementation UITableView (Extends)

- (void)scrollToBottomWithAnimation:(BOOL)animation {
    if (self.contentSize.height <= self.jx_height) {
        return;
    }
    NSUInteger sections = [self numberOfSections];
    NSUInteger rows = [self numberOfRowsInSection:sections - 1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows - 1 inSection:sections - 1];
    [self scrollToRowAtIndexPath:indexPath
                  atScrollPosition:UITableViewScrollPositionBottom
                          animated:animation];
}

@end
