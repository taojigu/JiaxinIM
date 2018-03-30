//
//  JXShowView.m
//  JXUIKit
//
//  Copyright © 2016年 DY. All rights reserved.
//

#import "JXShowView.h"
#import "JXActionView.h"
#import "JXMessage+Extends.h"
#import "JXWebViewController.h"

@interface JXShowView ()<JXActionViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
@property(nonatomic, strong) JXActionView *showView;
@property(nonatomic, strong) UIButton *coverBtn;
@end

@implementation JXShowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self loadShowView];
    }
    return self;
}

- (void)loadShowView {
    NSArray *matchs = [_message urlMatches];
    NSMutableArray *resultArray = [NSMutableArray array];
    CGFloat showViewHeight = 0;
    for (NSTextCheckingResult *match in matchs) {
        if (match.resultType == NSTextCheckingTypePhoneNumber) {
            [resultArray addObject:match];
            CGFloat textHeight = [self getTextHeightWithText:match.phoneNumber];
            textHeight = textHeight > 60 ? textHeight : 60;
            showViewHeight += textHeight;

        } else if (match.resultType == NSTextCheckingTypeLink) {
            [resultArray addObject:match];
            CGFloat textHeight = [self getTextHeightWithText:match.URL.absoluteString];
            textHeight = textHeight > 60 ? textHeight : 60;
            showViewHeight += textHeight;
        }
    }

    [self endEditing:YES];
    if (resultArray.count) {
        CGFloat height = showViewHeight + 30;
        height = height > self.bounds.size.height ? self.bounds.size.height : height;
        self.showView =
                [[JXActionView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height,
                                                               self.bounds.size.width, height)];
        self.showView.delegate = self;
        self.showView.dataSource = resultArray;

        [self addSubview:self.showView];
        self.coverBtn = [[UIButton alloc]
                initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];

        self.coverBtn.backgroundColor = [UIColor blackColor];
        self.coverBtn.alpha = 0.3;
        [self.coverBtn addTarget:self
                          action:@selector(clickBtn:)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.coverBtn];
        [self bringSubviewToFront:self.coverBtn];
        [self bringSubviewToFront:self.showView];
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.showView.transform = CGAffineTransformMakeTranslation(0, -height);
                         }];
    }
}

- (CGFloat)getTextHeightWithText:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingUsesFontLeading
                                    attributes:@{
                                        NSFontAttributeName : [UIFont systemFontOfSize:16]
                                    }
                                       context:nil]
                          .size;
    return size.height;
}

- (void)clickBtn:(UIButton *)button {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.showView.transform = CGAffineTransformIdentity;
                     }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self.coverBtn removeFromSuperview];
                       [self.showView removeFromSuperview];
                       [self removeFromSuperview];
                   });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",
                                                                        actionSheet.title]]];
    }
}

#pragma mark - JXShowViewDelegate

- (void)didSelectedItem:(NSTextCheckingResult *)result {
    [self.showView removeFromSuperview];
    [self.coverBtn removeFromSuperview];
    if (result.resultType == NSTextCheckingTypePhoneNumber) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:result.phoneNumber
                                                           delegate:self
                                                  cancelButtonTitle:JXUIString(@"cancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:JXUIString(@"call"), nil];
        [sheet showInView:self];
        [self removeFromSuperview];

    } else if (result.resultType == NSTextCheckingTypeLink) {
        [self removeFromSuperview];
        JXWebViewController *netViewController = [[JXWebViewController alloc] init];
        netViewController.netString = result.URL.absoluteString;
        if ([self.delegate respondsToSelector:@selector(didSelectedUrlString:)]) {
            [self.delegate didSelectedUrlString:result.URL.absoluteString];
        }
    }
}

@end
