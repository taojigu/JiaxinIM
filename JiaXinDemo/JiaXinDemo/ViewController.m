//
//  ViewController.m
//  JiaXinDemo
//
//  Created by 顾吉涛 on 2018/3/29.
//  Copyright © 2018年 顾吉涛. All rights reserved.
//

#import "ViewController.h"
#import <JXMCSUserManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonClicked:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [[JXMCSUserManager sharedInstance] loginWithCallback:^(BOOL success, id response) {

        if (success) {
            [[JXMCSUserManager sharedInstance] requestCSForUI:weakSelf.navigationController];
        } else {
            NSLog(@"%@", response);
        }
    }];
}


@end
