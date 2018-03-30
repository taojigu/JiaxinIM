//
//  JXMessageToolbar.m
//

#import "JXMessageToolbar.h"

#import "JXEmotion.h"
#import "JXEmotion.h"
#import "JXSDKHelper.h"
#import "JXToolBarMoreView.h"

#define JudgeMoreView                                                     \
if (!self.moreView) {                                                 \
self.moreView = [[JXToolBarMoreView alloc] init];                 \
} else {                                                              \
NSAssert([self.moreView isKindOfClass:[JXToolBarMoreView class]], \
@"moreView type error, must be JXToolBarMoreView");                     \
}

@implementation JXMessageToolbarItem

- (instancetype)initWithButton:(UIButton *)button withView:(UIView *)button2View {
    self = [super init];
    if (self) {
        _button = button;
        _button2View = button2View;
    }
    return self;
}

@end

@interface JXMessageToolbar ()<UITextViewDelegate, JXFaceDelegate, JXRecordViewDelegate>

@property(nonatomic) CGFloat version;

@property(nonatomic) NSMutableArray *leftItems;
@property(nonatomic) NSMutableArray *rightItems;

/**
 *  背景
 */
@property(nonatomic) UIImageView *toolbarBackgroundImageView;
@property(nonatomic) UIImageView *backgroundImageView;

/**
 *  底部扩展页面
 */
@property(nonatomic) BOOL isShowButtomView;
@property(nonatomic) UIView *activityButtomView;

/**
 *  按钮、toolbarView
 */
@property(nonatomic) UIView *toolbarView;
@property(nonatomic) UIButton *moreButton;
@property(nonatomic) UIButton *recordButton;
@property(nonatomic) UIButton *faceButton;

/**
 *  输入框
 */
@property(nonatomic) CGFloat previousTextViewContentHeight;
@property(nonatomic) NSLayoutConstraint *inputViewWidthItemsLeftConstraint;
@property(nonatomic) NSLayoutConstraint *inputViewWidthoutItemsLeftConstraint;

@property(nonatomic) NSArray *defaultEmoji;

@property(nonatomic, assign) BOOL isWechat;
@property(nonatomic, copy) NSMutableAttributedString *sendWechatStr;
@property(nonatomic, strong) NSArray *wechatExpressions;

@end

@implementation JXMessageToolbar

@synthesize faceView = _faceView;
@synthesize moreView = _moreView;
@synthesize recordView = _recordView;

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame
             horizontalPadding:8
               verticalPadding:5
            inputViewMinHeight:36
            inputViewMaxHeight:100];
}

- (instancetype)initWithFrame:(CGRect)frame
            horizontalPadding:(CGFloat)horizontalPadding
              verticalPadding:(CGFloat)verticalPadding
           inputViewMinHeight:(CGFloat)inputViewMinHeight
           inputViewMaxHeight:(CGFloat)inputViewMaxHeight {
    if (frame.size.height < (verticalPadding * 2 + inputViewMinHeight)) {
        frame.size.height = verticalPadding * 2 + inputViewMinHeight;
    }
    if (self = [super initWithFrame:frame]) {
        _horizontalPadding = horizontalPadding;
        _verticalPadding = verticalPadding;
        _inputViewMinHeight = inputViewMinHeight;
        _inputViewMaxHeight = inputViewMaxHeight;
        
        _leftItems = [NSMutableArray array];
        _rightItems = [NSMutableArray array];
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _activityButtomView = nil;
        _isShowButtomView = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(chatKeyboardWillChangeFrame:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    _delegate = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self _setupSubviews];
}

#pragma mark - setup subviews

- (void)_setupSubviews {
    [self removeAllSubviews];
    // backgroundImageView
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.autoresizingMask =
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundImageView.image = [UIImage imageWithColor:JXColorWithRGB(250, 250, 250)];
    [self addSubview:_backgroundImageView];
    
    // toolbar
    _toolbarView = [[UIView alloc] initWithFrame:self.bounds];
    _toolbarView.backgroundColor = [UIColor clearColor];
    _toolbarView.layer.borderWidth = 0.65f;
    _toolbarView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
    [self addSubview:_toolbarView];
    
    _toolbarBackgroundImageView =
    [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _toolbarView.frame.size.width,
                                                  _toolbarView.frame.size.height)];
    _toolbarBackgroundImageView.autoresizingMask =
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _toolbarBackgroundImageView.backgroundColor = [UIColor clearColor];
    [_toolbarView addSubview:_toolbarBackgroundImageView];
    
    //输入框
    _inputTextView = [[JXMessageTextView alloc]
                      initWithFrame:CGRectMake(self.horizontalPadding, self.verticalPadding,
                                               self.frame.size.width - self.verticalPadding * 2,
                                               self.frame.size.height - self.verticalPadding * 2)];
    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _inputTextView.scrollEnabled = YES;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES;    // UITextView内部判断send按钮是否可以用
    _inputTextView.placeHolder = JXUIString(@"please input content");
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    _previousTextViewContentHeight = [self _getTextViewContentH:_inputTextView];
    [_toolbarView addSubview:_inputTextView];
    
    if ([self.delegate respondsToSelector:@selector(toolBarAllowVoiceChat:)] &&
        [self.delegate toolBarAllowVoiceChat:self]) {
        //转变输入样式
        if (!self.isHiddenRecordBtn) {
            UIButton *styleChangeButton = [[UIButton alloc] init];
            styleChangeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [styleChangeButton setImage:JXChatImage(@"chatInput_Voice")
                               forState:UIControlStateNormal];
            [styleChangeButton setImage:JXChatImage(@"chatInput_Voice")
                               forState:UIControlStateSelected];
            [styleChangeButton addTarget:self
                                  action:@selector(styleButtonAction:)
                        forControlEvents:UIControlEventTouchUpInside];
            
            JXMessageToolbarItem *styleItem =
            [[JXMessageToolbarItem alloc] initWithButton:styleChangeButton withView:nil];
            [self setInputViewLeftItems:@[ styleItem ]];
        }
        
        //录制
        self.recordButton = [[UIButton alloc] initWithFrame:self.inputTextView.frame];
        self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        UIImage *normalImage = [UIImage imageWithColor:[UIColor whiteColor]];
        UIImage *highLightedImage = [UIImage imageWithColor:[UIColor colorWithWhite:0.9 alpha:1]];
        [self.recordButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [self.recordButton setBackgroundImage:highLightedImage forState:UIControlStateDisabled];
        [self.recordButton setBackgroundImage:normalImage forState:UIControlStateHighlighted];
        self.recordButton.layer.cornerRadius = 6.0f;
        self.recordButton.clipsToBounds = YES;
        self.recordButton.layer.borderWidth = 0.65f;
        self.recordButton.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        [self.recordButton setTitle:kTouchToRecord forState:UIControlStateNormal];
        [self.recordButton setTitle:kTouchToFinish forState:UIControlStateDisabled];
        self.recordButton.hidden = YES;
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(recordBtnLongPress:)];
        longPress.minimumPressDuration = 0.5f;
        [self.recordButton addGestureRecognizer:longPress];
        self.recordButton.hidden = YES;
        [self.toolbarView addSubview:self.recordButton];
    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    if ([self.delegate respondsToSelector:@selector(toolBarAllowEmojiChat:)] &&
        [self.delegate toolBarAllowEmojiChat:self]) {
        if (!self.isHiddenEmojiBtn) {
            //表情
            self.faceButton = [[UIButton alloc] init];
            self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self.faceButton setImage:JXChatImage(@"chatInput_face") forState:UIControlStateNormal];
            [self.faceButton setImage:JXChatImage(@"chatInput_face")
                             forState:UIControlStateHighlighted];
            [self.faceButton setImage:JXChatImage(@"chatInput_face") forState:UIControlStateSelected];
            [self.faceButton addTarget:self
                                action:@selector(faceButtonAction:)
                      forControlEvents:UIControlEventTouchUpInside];
            JXMessageToolbarItem *faceItem =
            [[JXMessageToolbarItem alloc] initWithButton:self.faceButton
                                                withView:self.faceView];
            [items addObject:faceItem];
        }
    }
    
    //更多
    self.moreButton = [[UIButton alloc] init];
    self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.moreButton setImage:JXChatImage(@"chatInput_more") forState:UIControlStateNormal];
    [self.moreButton setImage:JXChatImage(@"chatInput_more") forState:UIControlStateHighlighted];
    [self.moreButton setImage:JXChatImage(@"chatInput_key") forState:UIControlStateSelected];
    [self.moreButton addTarget:self
                        action:@selector(moreButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    JXMessageToolbarItem *moreItem =
    [[JXMessageToolbarItem alloc] initWithButton:self.moreButton withView:self.moreView];
    [items addObject:moreItem];
    
    [self setInputViewRightItems:items];
}

- (void)setupFaceView {
    NSMutableArray *packages = [NSMutableArray array];
    if (self.isShowWechatBar) {
        JXEmotionPackage *wechatPackage = [[JXEmotionPackage alloc] initWithEmotions:[self wechatExpressions]
                                                                             andType:JXEmotionTypeNomal];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
        NSArray *faces = [JXEmotion emotionsWithPlistPath:path];
        JXEmotionPackage *emojiPackage = [[JXEmotionPackage alloc] initWithEmotions:faces
                                                                            andType:JXEmotionTypeEmoji];
        
        [packages addObject:wechatPackage];
        [packages addObject:emojiPackage];
    } else {
        JXEmotionPackage *defaultPackage = [[JXEmotionPackage alloc] initWithEmotions:self.defaultEmoji
                                                                              andType:JXEmotionTypeNomal];
        [packages addObject:defaultPackage];
    }
    [(JXFaceView *)_faceView setEmotionPackages:packages];
}

- (BOOL)resignFirstResponder {
    //录音状态下，不显示底部扩展页面
    [self _willShowBottomView:nil];
    
    //将inputTextView内容置空，以使toolbarView回到最小高度
    self.inputTextView.text = @"";
    [self textViewDidChange:self.inputTextView];
    [self.inputTextView resignFirstResponder];
    return [super resignFirstResponder];
    
}

#pragma mark - getter

- (UIView *)recordView {
    if (_recordView == nil) {
        _recordView = [[JXRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
        JXRecordView *recordView = (JXRecordView *)_recordView;
        recordView.delegate = self;
    }
    return _recordView;
}

- (UIView *)faceView {
    if (_faceView == nil) {
        _faceView =
        [[JXFaceView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_toolbarView.frame),
                                                     self.frame.size.width, 200)];
        [(JXFaceView *)_faceView setDelegate:self];
        _faceView.backgroundColor = JXColorWithRGB(240, 242, 247);
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        //        self.isShowWechatBar = [JXUserDefault boolForKey:kShowWechatFaceBar];
        [self setupFaceView];
    }
    return _faceView;
}

- (NSString *)text {
    return self.inputTextView.text.copy;
}

- (NSArray *)wechatExpressions {
    if (_wechatExpressions == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"wechatFaceList" ofType:@"plist"];
        _wechatExpressions = [JXEmotion emotionsWithPlistPath:path];
    }
    return _wechatExpressions;
}

- (NSArray *)defaultEmoji {
    if (_defaultEmoji == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"JXUIResources.bundle/jiaxinFaceList"
                                                         ofType:@"plist"];
        _defaultEmoji = [JXEmotion emotionsWithPlistPath:path];
    }
    return _defaultEmoji;
}

#pragma mark - setter

- (void)setDelegate:(id<JXMessageToolbarDelegate>)delegate {
    _delegate = delegate;
}

- (void)setRecordView:(UIView *)recordView {
    if (_recordView != recordView) {
        _recordView = recordView;
    }
}

- (void)setMoreView:(UIView *)moreView {
    if (_moreView != moreView) {
        _moreView = moreView;
        
        for (JXMessageToolbarItem *item in self.rightItems) {
            if (item.button == self.moreButton) {
                item.button2View = _moreView;
                break;
            }
        }
    }
}

- (void)setFaceView:(UIView *)faceView {
    if (_faceView != faceView) {
        _faceView = faceView;
        
        for (JXMessageToolbarItem *item in self.rightItems) {
            if (item.button == self.faceButton) {
                item.button2View = _faceView;
                break;
            }
        }
    }
}

- (void)setInputViewLeftItems:(NSArray *)inputViewLeftItems {
    for (JXMessageToolbarItem *item in self.leftItems) {
        [item.button removeFromSuperview];
        [item.button2View removeFromSuperview];
    }
    [self.leftItems removeAllObjects];
    
    _inputViewLeftItems = inputViewLeftItems;
    
    CGFloat oX = self.horizontalPadding;
    CGFloat itemHeight = self.toolbarView.frame.size.height - self.verticalPadding * 2;
    for (id item in inputViewLeftItems) {
        if ([item isKindOfClass:[JXMessageToolbarItem class]]) {
            JXMessageToolbarItem *chatItem = (JXMessageToolbarItem *)item;
            if (chatItem.button) {
                CGRect itemFrame = chatItem.button.frame;
                if (itemFrame.size.height == 0) {
                    itemFrame.size.height = itemHeight;
                }
                
                if (itemFrame.size.width == 0) {
                    itemFrame.size.width = itemFrame.size.height;
                }
                
                itemFrame.origin.x = oX;
                itemFrame.origin.y =
                (self.toolbarView.frame.size.height - itemFrame.size.height) / 2;
                chatItem.button.frame = itemFrame;
                oX += (itemFrame.size.width + self.horizontalPadding);
                
                [self.toolbarView addSubview:chatItem.button];
                [self.leftItems addObject:chatItem];
            }
        }
    }
    
    CGRect inputFrame = self.inputTextView.frame;
    CGFloat value = inputFrame.origin.x - oX;
    inputFrame.origin.x = oX;
    inputFrame.size.width += value;
    self.inputTextView.frame = inputFrame;
    
    CGRect recordFrame = self.recordButton.frame;
    recordFrame.origin.x = inputFrame.origin.x;
    recordFrame.size.width = inputFrame.size.width;
    self.recordButton.frame = recordFrame;
}

- (void)setInputViewRightItems:(NSArray *)inputViewRightItems {
    for (JXMessageToolbarItem *item in self.rightItems) {
        [item.button removeFromSuperview];
        [item.button2View removeFromSuperview];
    }
    [self.rightItems removeAllObjects];
    
    _inputViewRightItems = inputViewRightItems;
    
    CGFloat oMaxX = self.toolbarView.frame.size.width - self.horizontalPadding;
    CGFloat itemHeight = self.toolbarView.frame.size.height - self.verticalPadding * 2;
    if ([inputViewRightItems count] > 0) {
        for (NSInteger i = (inputViewRightItems.count - 1); i >= 0; i--) {
            id item = [inputViewRightItems objectAtIndex:i];
            if ([item isKindOfClass:[JXMessageToolbarItem class]]) {
                JXMessageToolbarItem *chatItem = (JXMessageToolbarItem *)item;
                if (chatItem.button) {
                    CGRect itemFrame = chatItem.button.frame;
                    if (itemFrame.size.height == 0) {
                        itemFrame.size.height = itemHeight;
                    }
                    
                    if (itemFrame.size.width == 0) {
                        itemFrame.size.width = itemFrame.size.height;
                    }
                    
                    oMaxX -= itemFrame.size.width;
                    itemFrame.origin.x = oMaxX;
                    itemFrame.origin.y =
                    (self.toolbarView.frame.size.height - itemFrame.size.height) / 2;
                    chatItem.button.frame = itemFrame;
                    oMaxX -= self.horizontalPadding;
                    
                    [self.toolbarView addSubview:chatItem.button];
                    [self.rightItems addObject:item];
                }
            }
        }
    }
    
    CGRect inputFrame = self.inputTextView.frame;
    CGFloat value = oMaxX - CGRectGetMaxX(inputFrame);
    inputFrame.size.width += value;
    self.inputTextView.frame = inputFrame;
    
    CGRect recordFrame = self.recordButton.frame;
    recordFrame.origin.x = inputFrame.origin.x;
    recordFrame.size.width = inputFrame.size.width;
    self.recordButton.frame = recordFrame;
}

- (void)setIsHiddenRecordBtn:(BOOL)isHiddenRecordBtn {
    _isHiddenRecordBtn = isHiddenRecordBtn;
    self.recordButton.hidden = isHiddenRecordBtn;
    [self _setupSubviews];
}

- (void)setIsHiddenEmojiBtn:(BOOL)isHiddenEmojiBtn {
    _isHiddenEmojiBtn = isHiddenEmojiBtn;
    self.faceButton.hidden = isHiddenEmojiBtn;
    [self _setupSubviews];
}

- (void)setIsShowWechatBar:(BOOL)isShowWechatBar {
    _isShowWechatBar = isShowWechatBar;
    [self setupFaceView];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

#pragma mark - private input view

- (CGFloat)_getTextViewContentH:(UITextView *)textView {
    if (self.version >= 7.0) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

- (void)_willShowInputTextViewToHeight:(CGFloat)toHeight {
    if (toHeight < self.inputViewMinHeight) {
        toHeight = self.inputViewMinHeight;
    }
    if (toHeight > self.inputViewMaxHeight) {
        toHeight = self.inputViewMaxHeight;
    }
    
    if (toHeight == _previousTextViewContentHeight) {
        return;
    } else {
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        
//        if (self.version < 7.0) {
        [self.inputTextView
         setContentOffset:CGPointMake(0.0f, (self.inputTextView.contentSize.height -
                                             self.inputTextView.frame.size.height) /
                                      2)
         animated:YES];
//        }
        _previousTextViewContentHeight = toHeight;
        
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
            [_delegate didChangeFrameToHeight:self.frame.size.height];
        }
    }
}

#pragma mark - private bottom view

- (void)_willShowBottomHeight:(CGFloat)bottomHeight {
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    CGRect toFrame =
    CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight),
               fromFrame.size.width, toHeight);
    
    //如果需要将所有扩展页面都隐藏，而此时已经隐藏了所有扩展页面，则不进行任何操作
    if (bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height) {
        return;
    }
    
    if (bottomHeight == 0) {
        self.isShowButtomView = NO;
    } else {
        self.isShowButtomView = YES;
    }
    
    self.frame = toFrame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
        [_delegate didChangeFrameToHeight:toHeight];
    }
}

- (void)_willShowBottomView:(UIView *)bottomView {
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self _willShowBottomHeight:bottomHeight];
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

- (void)_willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame {
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        //一定要把 self.activityButtomView 置为空
        [self _willShowBottomHeight:toFrame.size.height - JXSafeAreaBottom];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    } else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        [self _willShowBottomHeight:0];
    } else {
        [self _willShowBottomHeight:toFrame.size.height - JXSafeAreaBottom];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    
    for (JXMessageToolbarItem *item in self.leftItems) {
        item.button.selected = NO;
    }
    
    for (JXMessageToolbarItem *item in self.rightItems) {
        item.button.selected = NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            NSString *attStr = [JXEmotion mutableStringWithText:textView.text];
            [self.delegate didSendText:attStr];    // song
            self.inputTextView.text = @"";
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
        }
        
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self _willShowInputTextViewToHeight:[self _getTextViewContentH:textView]];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidValueChange:)]) {
        [self.delegate inputTextViewDidValueChange:self.inputTextView];
    }
}

#pragma mark - DXFaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete {
    NSString *chatText = self.inputTextView.text;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
                                       initWithAttributedString:self.inputTextView.attributedText];
    
    if (!isDelete && str.length > 0) {
        NSRange range = [self.inputTextView selectedRange];
        [attr insertAttributedString:[JXEmotion attStringFromTextForInputView:str]
                             atIndex:range.location];
        self.inputTextView.text = @"";
        self.inputTextView.attributedText = attr;
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.attributedText.length - 1, 1)];
        //        self.inputTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    } else {
        if (chatText.length > 0) {
            NSInteger length = 1;
            if (chatText.length >= 2) {
                NSString *subStr = [chatText substringFromIndex:chatText.length - 2];
                if ([_defaultEmoji containsObject:subStr]) {
                    length = 2;
                }
            }
            self.inputTextView.attributedText = [self backspaceText:attr length:length];
        }
    }
    
    [self textViewDidChange:self.inputTextView];
}

- (NSMutableAttributedString *)backspaceText:(NSMutableAttributedString *)attr
                                      length:(NSInteger)length {
    NSRange range = [self.inputTextView selectedRange];
    if (range.location == 0) {
        return attr;
    }
    [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
    return attr;
}

- (void)sendFace {
    NSString *chatText = self.inputTextView.text;
    if (chatText.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            if (![_inputTextView.text isEqualToString:@""]) {
                //转义回来
                NSMutableString *attStr = [[NSMutableString alloc]
                                           initWithString:self.inputTextView.attributedText.string];
                [_inputTextView.attributedText
                 enumerateAttribute:NSAttachmentAttributeName
                 inRange:NSMakeRange(0, self.inputTextView.attributedText.length)
                 options:NSAttributedStringEnumerationReverse
                 usingBlock:^(id value, NSRange range, BOOL *stop) {
                     if (value) {
                         JXTextAttachment *attachment = (JXTextAttachment *)value;
                         NSString *str = [NSString
                                          stringWithFormat:@"\\::a%@]", attachment.imageName];
                         [attStr replaceCharactersInRange:range withString:str];
                     }
                 }];
                attStr = [JXEmotion mutableStringWithText:attStr];
                [self.delegate didSendText:attStr];
                self.inputTextView.text = @"";
                [self _willShowInputTextViewToHeight:
                 [self _getTextViewContentH:self.inputTextView]];
            }
        }
    }
}

- (void)sendFaceWithEmotion:(NSString *)emotion {
    if (emotion.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:JXUIString(@"emoji")
                               withExt:@{
                                         @"em_emotion" : emotion
                                         }];
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
            ;
        }
    }
}

#pragma mark - JXRecordViewDelegate

- (double)currentVolume {
    if ([self.delegate respondsToSelector:@selector(currentVolume)]) {
        return [self.delegate currentVolume];
    }
    return 1.0;
}

#pragma mark - UIKeyboardNotification

- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void (^animations)(void) = ^{
        [self _willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState)
                     animations:animations
                     completion:nil];
}

#pragma mark - action

- (void)styleButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        for (JXMessageToolbarItem *item in self.rightItems) {
            item.button.selected = NO;
        }
        
        for (JXMessageToolbarItem *item in self.leftItems) {
            if (item.button != button) {
                item.button.selected = NO;
            }
        }
        
        //录音状态下，不显示底部扩展页面
        [self _willShowBottomView:nil];
        
        //将inputTextView内容置空，以使toolbarView回到最小高度
        self.inputTextView.text = @"";
        [self textViewDidChange:self.inputTextView];
        [self.inputTextView resignFirstResponder];
    } else {
        //键盘也算一种底部扩展页面
        [self.inputTextView becomeFirstResponder];
    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.recordButton.hidden = !button.selected;
                         self.inputTextView.hidden = button.selected;
                     }
                     completion:nil];
}

- (void)faceButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    JXMessageToolbarItem *faceItem = nil;
    for (JXMessageToolbarItem *item in self.rightItems) {
        if (item.button == button) {
            faceItem = item;
            continue;
        }
        
        item.button.selected = NO;
    }
    
    for (JXMessageToolbarItem *item in self.leftItems) {
        item.button.selected = NO;
    }
    
    if (button.selected) {
        //如果处于文字输入状态，使文字输入框失去焦点
        [self.inputTextView resignFirstResponder];
        
        [self _willShowBottomView:faceItem.button2View];
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.recordButton.hidden = button.selected;
                             self.inputTextView.hidden = !button.selected;
                         }
                         completion:^(BOOL finished){
                             
                         }];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)moreButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    JXMessageToolbarItem *moreItem = nil;
    for (JXMessageToolbarItem *item in self.rightItems) {
        if (item.button == button) {
            moreItem = item;
            continue;
        }
        item.button.selected = NO;
    }
    
    for (JXMessageToolbarItem *item in self.leftItems) {
        item.button.selected = NO;
    }
    
    if (button.selected) {
        //如果处于文字输入状态，使文字输入框失去焦点
        [self.inputTextView resignFirstResponder];
        [self _willShowBottomView:moreItem.button2View];
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.recordButton.hidden = button.selected;
                             self.inputTextView.hidden = !button.selected;
                         }
                         completion:nil];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)recordButtonTouchDown {
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [_delegate didStartRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpOutside {
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)]) {
        [_delegate didCancelRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpInside {
    self.recordButton.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(didFinishRecordingVoiceAction:)]) {
        [self.delegate didFinishRecordingVoiceAction:self.recordView];
    }
    self.recordButton.enabled = YES;
}

- (void)recordDragOutside {
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)]) {
        [self.delegate didDragOutsideAction:self.recordView];
    }
}

- (void)recordDragInside {
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)]) {
        [self.delegate didDragInsideAction:self.recordView];
    }
}

- (void)recordBtnLongPress:(UIGestureRecognizer *)ges {
    switch (ges.state) {
        case UIGestureRecognizerStateBegan : {
            self.recordButton.enabled = NO;
            if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
                [_delegate didStartRecordingVoiceAction:self.recordView];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [ges locationInView:self];
            if (point.y < 0) {
                if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)]) {
                    [self.delegate didDragOutsideAction:self.recordView];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)]) {
                    [self.delegate didDragInsideAction:self.recordView];
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint point = [ges locationInView:self];
            if (point.y > 0) {
                self.recordButton.enabled = YES;
                if ([self.delegate respondsToSelector:@selector(didFinishRecordingVoiceAction:)]) {
                    [self.delegate didFinishRecordingVoiceAction:self.recordView];
                }
            } else {
                self.recordButton.enabled = YES;
                if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)]) {
                    [_delegate didCancelRecordingVoiceAction:self.recordView];
                }
            }
            break;
        }
        case UIGestureRecognizerStateFailed: {
            self.recordButton.enabled = YES;
            break;
        }
        default: {
            self.recordButton.enabled = YES;
            break;
        }
    }
}

#pragma mark - public

/**
 *  默认高度
 *
 *  @return 默认高度
 */
+ (CGFloat)defaultHeight {
    return 5 * 2 + 36;
}

/**
 *  停止编辑
 */
- (BOOL)endEditing:(BOOL)force {
    BOOL result = [super endEditing:force];
    
    //    for (JXMessageToolbarItem *item in self.leftItems) {
    //        item.button.selected = NO;
    //    }
    
    for (JXMessageToolbarItem *item in self.rightItems) {
        item.button.selected = NO;
    }
    [self _willShowBottomView:nil];
    
    return result;
}

/**
 *  取消触摸录音键
 */
- (void)cancelTouchRecord {
    if ([_recordView isKindOfClass:[JXRecordView class]]) {
        [(JXRecordView *)_recordView recordButtonTouchUpInside];
        [_recordView removeFromSuperview];
    }
}

/**
 *  使用默认的更多附加界面
 */
- (void)setupDefaultMoreView {
    self.moreView = [[JXToolBarMoreView alloc] init];
    [self moreViewAddPhotoItemWithTitle:nil andImage:nil];
    [self moreViewAddCameraItemWithTitle:nil andImage:nil];
    [self moreViewAddAudioCallItemWithTitle:nil andImage:nil];
    [self moreViewAddVideoCallItemWithTitle:nil andImage:nil];
    [self moreViewAddLocationItemWithTitle:nil andImage:nil];
}

- (void)moreViewAddPhotoItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    JudgeMoreView;
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView addItemWithTitle:title.length ? title : @"Image"
                      andImage:image ? image : JXChatImage(@"moreIcon_image")
                     andAction:^(NSInteger index) {
                         [weakSelf photoAction];
                     }];
    
    self.moreView.frame =
    CGRectMake(0, CGRectGetMaxY(self.frame), self.moreView.intrinsicContentSize.width,
               self.moreView.intrinsicContentSize.height);
}

- (void)moreViewAddCameraItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    JudgeMoreView;
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView addItemWithTitle:title.length ? title : @"Photo"
                      andImage:image ? image : JXChatImage(@"MoreIcon_MakePhoto")
                     andAction:^(NSInteger index) {
                         [weakSelf takePicAction];
                     }];
    
    self.moreView.frame =
    CGRectMake(0, CGRectGetMaxY(self.frame), self.moreView.intrinsicContentSize.width,
               self.moreView.intrinsicContentSize.height);
}

- (void)moreViewAddVideoItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    JudgeMoreView;
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView addItemWithTitle:title.length ? title : @"Video"
                      andImage:image ? image : JXChatImage(@"moreIcon_videaChat")
                     andAction:^(NSInteger index) {
                         [weakSelf videoAction];
                     }];
    self.moreView.frame =
    CGRectMake(0, CGRectGetMaxY(self.frame), self.moreView.intrinsicContentSize.width,
               self.moreView.intrinsicContentSize.height);
}

- (void)moreViewAddLocationItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    JudgeMoreView;
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView addItemWithTitle:title.length ? title : @"Location"
                      andImage:image ? image : JXChatImage(@"MoreIcon_Location")
                     andAction:^(NSInteger index) {
                         [weakSelf locationAction];
                     }];
    
    self.moreView.frame =
    CGRectMake(0, CGRectGetMaxY(self.frame), self.moreView.intrinsicContentSize.width,
               self.moreView.intrinsicContentSize.height);
}

- (void)moreViewAddAudioCallItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    JudgeMoreView;
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView addItemWithTitle:title.length ? title : @"AudioCall"
                      andImage:image ? image : JXChatImage(@"more_icon_voiceChat")
                     andAction:^(NSInteger index) {
                         [weakSelf takeAudioCallAction];
                     }];
    
    self.moreView.frame =
    CGRectMake(0, CGRectGetMaxY(self.frame), self.moreView.intrinsicContentSize.width,
               self.moreView.intrinsicContentSize.height);
}

- (void)moreViewAddVideoCallItemWithTitle:(NSString *)title andImage:(UIImage *)image {
    JudgeMoreView;
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView addItemWithTitle:title.length ? title : @"VideoCall"
                      andImage:image ? image : JXChatImage(@"moreIcon_videaChat")
                     andAction:^(NSInteger index) {
                         [weakSelf takeVideoCallAction];
                     }];
    
    self.moreView.frame =
    CGRectMake(0, CGRectGetMaxY(self.frame), self.moreView.intrinsicContentSize.width,
               self.moreView.intrinsicContentSize.height);
}

- (void)moreViewAddCustomItemWithTitle:(NSString *)title
                              andImage:(UIImage *)image
                             andAction:(void (^)(NSInteger))action {
    if (!self.moreView) {
        self.moreView = [[JXToolBarMoreView alloc] init];
    }
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView addItemWithTitle:title
                      andImage:image
                     andAction:^(NSInteger index) {
                         [weakSelf customItemActionWithIndex:index andAction:action];
                     }];
    
    moreView.frame = CGRectMake(0, CGRectGetMaxY(self.frame), moreView.intrinsicContentSize.width,
                                moreView.intrinsicContentSize.height);
}

- (void)moreViewDeleteCustomItemWithTitle:(NSString *)title
                                 andImage:(UIImage *)image
                                andAction:(void (^)(NSInteger))action {
    if (!self.moreView) {
        self.moreView = [[JXToolBarMoreView alloc] init];
    }
    JXToolBarMoreView *moreView = (JXToolBarMoreView *)self.moreView;
    WEAKSELF;
    [moreView deleteItemWithTitle:title
                         andImage:image
                        andAction:^(NSInteger index) {
                            [weakSelf customItemActionWithIndex:index andAction:action];
                        }];
    
    moreView.frame = CGRectMake(0, CGRectGetMaxY(self.frame), moreView.intrinsicContentSize.width,
                                moreView.intrinsicContentSize.height);
}
#pragma mark - moreviewItem action

- (void)takePicAction {
    if ([self.delegate respondsToSelector:@selector(didSelectedCameraAction:)]) {
        [self.delegate didSelectedCameraAction:self.moreView];
    }
}

- (void)photoAction {
    if ([self.delegate respondsToSelector:@selector(didSelectedPhotoAction:)]) {
        [self.delegate didSelectedPhotoAction:self.moreView];
    }
}

- (void)videoAction {
    if ([self.delegate respondsToSelector:@selector(didSelectedVideoAction:)]) {
        [self.delegate didSelectedVideoAction:self.moreView];
    }
}

- (void)locationAction {
    if ([self.delegate respondsToSelector:@selector(didselectedLocationAction:)]) {
        [self.delegate didselectedLocationAction:self.moreView];
    }
}

- (void)takeAudioCallAction {
    if ([self.delegate respondsToSelector:@selector(didSelectedAudioCallAction:)]) {
        [self.delegate didSelectedAudioCallAction:self.moreView];
    }
}

- (void)takeVideoCallAction {
    if ([self.delegate respondsToSelector:@selector(didSelectedVideoCallAction:)]) {
        [self.delegate didSelectedVideoCallAction:self.moreView];
    }
}

- (void)customItemActionWithIndex:(NSInteger)index andAction:(void (^)(NSInteger idx))action {
    if ([self.delegate respondsToSelector:@selector(didselectedCustomItemIndex:)]) {
        action = nil;
        [self.delegate didselectedCustomItemIndex:index];
    } else {
        action(index);
    }
}

//- (void)moreAction:(id)sender
//{
//    UIButton *button = (UIButton*)sender;
//    if (button && _delegate && [_delegate
//    respondsToSelector:@selector(moreView:didItemInMoreViewAtIndex:)]) {
//        [_delegate moreView:self didItemInMoreViewAtIndex:button.tag-MOREVIEW_BUTTON_TAG];
//    }
//}

@end
