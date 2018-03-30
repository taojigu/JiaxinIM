//
//  JXBaseTableViewController.m
//  im_demo
//
//  Created by raymond on 16/5/18.
//  Copyright © 2016年 佳信. All rights reserved.
//

#import "JXBaseTableViewController.h"

@interface JXBaseTableViewController ()

@end

@implementation JXBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tb]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{
                                                                            @"tb" : self.tableView
                                                                        }]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tb]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{
                                                                            @"tb" : self.tableView
                                                                        }]];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super init]) {
        _style = style;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.style];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tableView;
}

@end
