//
// JXFacialView.m
//

#import "JXEmotion.h"
#import "JXFaceView.h"
#import "JXFacialView.h"
#import "JXSDKHelper.h"

@interface JXFacialView ()<UIScrollViewDelegate> {
    NSMutableArray *_faces;
}

@property(nonatomic, strong) UIScrollView *scrollview;
@property(nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic, strong) NSArray *expressions;
@property(nonatomic, strong) NSArray *defaultExpressions;
@end

@implementation JXFacialView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollview = [[UIScrollView alloc] initWithFrame:frame];
        _scrollview.pagingEnabled = YES;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.alwaysBounceHorizontal = YES;
        _scrollview.delegate = self;
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _emotionRow = 3;
        _emotionCol = 7;
        [self addSubview:_scrollview];
        [self addSubview:_pageControl];
    }
    return self;
}

//给faces设置位置
- (void)loadFacialView:(JXEmotionPackage *)emotionPackage size:(CGSize)size {
    for (UIView *view in [self.scrollview subviews]) {
        [view removeFromSuperview];
    }

    [_scrollview setContentOffset:CGPointZero];
    NSInteger maxRow = self.emotionRow + 1;
    NSInteger maxCol = self.emotionCol;
    NSInteger pageSize = self.emotionRow * self.emotionCol;
    CGFloat itemWidth = self.frame.size.width / maxCol;
    CGFloat itemHeight = self.frame.size.height / maxRow;

    CGRect frame = self.frame;
    frame.size.height -= itemHeight;
    _scrollview.frame = frame;

    _faces = [NSMutableArray arrayWithArray:emotionPackage.emotions];
    NSInteger totalPage = [_faces count] % pageSize == 0 ? [_faces count] / pageSize
                                                         : [_faces count] / pageSize + 1;
    [_scrollview setContentSize:CGSizeMake(totalPage * CGRectGetWidth(self.frame),
                                           itemHeight * self.emotionRow)];

    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = totalPage;
    _pageControl.frame = CGRectMake(0, (maxRow - 1) * itemHeight + 5, CGRectGetWidth(self.frame),
                                    itemHeight - 10);

    for (int i = 0; i < totalPage; i++) {
        for (int row = 0; row < self.emotionRow; row++) {
            for (int col = 0; col < maxCol; col++) {
                NSInteger index = i * pageSize + row * maxCol + col;
                if (index != 0 && (index - (pageSize - 1)) % pageSize == 0) { // 删除按钮位置
                    [_faces insertObject:@"" atIndex:index];
                    break;
                }
                
                if (index < [_faces count]) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundColor:[UIColor clearColor]];
                    [button setFrame:CGRectMake(i * CGRectGetWidth(self.frame) + col * itemWidth,
                                                row * itemHeight, itemWidth, itemHeight)];
                    [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                    
                    JXEmotion *emotion = [_faces objectAtIndex:index];
                    if (emotionPackage.type == JXEmotionTypeNomal) {
                        [button setImage:JXChatImage(emotion.png) forState:UIControlStateNormal];
                        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        [button setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
                        [button addTarget:self
                                   action:@selector(selected:)
                         forControlEvents:UIControlEventTouchUpInside];
                        button.tag = index;
                    } else if (emotionPackage.type == JXEmotionTypeEmoji) {
                        [button setTitle:emotion.emoji
                                forState:UIControlStateNormal];
                        [button addTarget:self
                                   action:@selector(selectedEmoji:)
                         forControlEvents:UIControlEventTouchUpInside];
                        button.tag = index;
                    }

                    [_scrollview addSubview:button];
                } else {
                    break;
                }
            }
        }
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setBackgroundColor:[UIColor clearColor]];
        [deleteButton setFrame:CGRectMake(i * CGRectGetWidth(self.frame) +
                                                  (self.emotionCol - 1) * itemWidth,
                                          (self.emotionRow - 1) * itemHeight,
                                          itemWidth, itemHeight)];
        [deleteButton setImage:JXChatImage(@"faceDelete")
                      forState:UIControlStateNormal];
        deleteButton.tag = 10000;
        [deleteButton addTarget:self
                          action:@selector(selected:)
                forControlEvents:UIControlEventTouchUpInside];
        [_scrollview addSubview:deleteButton];
    }
}

- (void)selectedEmoji:(UIButton *)bt {
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    } else {
        NSString *str = [[_faces objectAtIndex:bt.tag] emoji];
        if (_delegate) {
            [_delegate selectedFacialView:str];
        }
    }
}

- (void)selected:(UIButton *)bt {
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    } else {
        JXEmotion *emoiton = [_faces objectAtIndex:bt.tag];
        if (_delegate) {
            [_delegate selectedFacialView:emoiton.chs];
        }
    }
}

- (void)sendGifAction:(UIButton *)bt {
    NSString *str = [_faces objectAtIndex:bt.tag];
    if (_delegate) {
        [_delegate sendFace:str];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

@end
