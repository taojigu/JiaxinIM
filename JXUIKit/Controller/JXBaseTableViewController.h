//
//  JXBaseTableViewController.h
//  im_demo
//
//  Created by raymond on 16/5/18.
//  Copyright © 2016年 佳信. All rights reserved.
//

#import "JXBaseViewController.h"

@interface JXBaseTableViewController : JXBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) UITableViewStyle style; // Defalut is UITableViewStylePlain;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end
