//
//  IMToolBarOptionView.h
//

#import "JXToolBarMoreView.h"

#import "JXSDKHelper.h"

#define kChatMoreOptionViewRowHeight 100
#define kItemSpace 10
#define kEndageSpaceX 15
#define kItemWidth 58
#define kItemHeight 76

#pragma mark -
#pragma mark - class IMChatMoreOptionItemView

@interface JXToolBarOptionItemView : UICollectionViewCell

@property(nonatomic, strong) UIImageView *cellImageView;
@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) JXToolBarOptionItem *item;

@end

@implementation JXToolBarOptionItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _cellImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _cellImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_cellImageView];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = JXPureColor(114.0);
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = JXSystemFont(13.0);

        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _cellImageView.frame = CGRectMake(0, 0, 58, 58);
    _titleLabel.frame = CGRectMake(_cellImageView.jx_left - 5, _cellImageView.jx_bottom, _cellImageView.jx_width + 10,
                                   self.jx_height - _cellImageView.jx_height);


}

- (void)setItem:(JXToolBarOptionItem *)item {
    _item = item;
    self.titleLabel.text = item.title;
    self.cellImageView.image = item.image;
}

@end

#pragma mark -
#pragma mark implementation IMChatMoreOptionItemData

@interface JXToolBarOptionItem ()

@property(nonatomic, copy) void (^action)(void);

@end

@implementation JXToolBarOptionItem

+ (instancetype)optionItemWithTitle:(NSString *)title
                           andImage:(UIImage *)image
                          andAction:(void (^)(void))action {
    JXToolBarOptionItem *item = [[JXToolBarOptionItem alloc] init];
    if (item) {
        item.title = title;
        item.image = image;
        item.action = action;
    }
    return item;
}

@end

#pragma mark -  implementation IMChatMoreOptionView

@interface JXToolBarMoreView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, strong) UICollectionView *contentView;
@property(nonatomic, strong) UIView *seplineView;
@property(nonatomic, strong) NSMutableArray *optionItems;
@end

@implementation JXToolBarMoreView

#pragma mark - public method

- (void)addItemWithTitle:(NSString *)title
                andImage:(UIImage *)image
               andAction:(void (^)(NSInteger index))action {
    NSInteger idx = self.optionItems.count;
    JXToolBarOptionItem *item = [JXToolBarOptionItem optionItemWithTitle:title
                                                                andImage:image
                                                               andAction:^{
                                                                   action(idx);
                                                               }];
    self.action = action;

     [self.optionItems addObject:item];


}

- (void)deleteItemWithTitle:(NSString *)title
                   andImage:(UIImage *)image
                  andAction:(void (^)(NSInteger index))action {
    JXToolBarOptionItem *delItem;
    for (JXToolBarOptionItem *item in self.optionItems) {
        if ([item.title isEqualToString:title]) {
            delItem = item;
            break;
        }
    }
    if ([self.optionItems containsObject:delItem]) {
        [self.optionItems removeObject:delItem];
        [self.contentView reloadData];
    }
}

- (CGSize)intrinsicContentSize {
    NSUInteger rowItemCount = floor((JXScreenSize.width - 2 * kEndageSpaceX + kItemSpace) /
                                    (kItemWidth + kItemSpace));
    int row = self.optionItems ? ceil((double)[self.optionItems count] / (double)rowItemCount) : 0;
    if (self.optionItems.count > 4) {
        row = 2;
    } else {
        row = 1;
    }
    return CGSizeMake(JXScreenSize.width, row * kChatMoreOptionViewRowHeight);
}

- (instancetype)initWithOptionItems:(NSMutableArray *)items {
    self = [super init];
    if (self) {
        _optionItems = items;
        [self loadContentView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _optionItems = nil;
        [self loadContentView];
    }
    return self;
}

- (void)loadContentView {
    _seplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.jx_width, JXMinPixels)];
    _seplineView.backgroundColor = kSeprateLineDefaultColor;
    [self addSubview:_seplineView];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    layout.minimumInteritemSpacing = ([UIScreen mainScreen].bounds.size.width - 4 * kItemWidth) / 5;
    layout.minimumLineSpacing = 20;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10, kEndageSpaceX, 10, kEndageSpaceX);

    _contentView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.jx_width, self.jx_height)
                                      collectionViewLayout:layout];
    _contentView.delegate = self;
    _contentView.dataSource = self;
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.allowsSelection = YES;
    _contentView.pagingEnabled =YES;
    //    _contentView.allowsMultipleSelection = YES;
    [_contentView registerClass:[JXToolBarOptionItemView class]
            forCellWithReuseIdentifier:[[JXToolBarOptionItemView class] description]];
    [self addSubview:_contentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _seplineView.frame = CGRectMake(0, 0, self.jx_width, JXMinPixels);
    _contentView.frame = CGRectMake(0, 0, self.jx_width, self.jx_height);
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView
        shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
        shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
        didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    JXToolBarOptionItem *item = self.optionItems[indexPath.row];
    if (item.action) {
        item.action();
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView
        shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //    if(0 == indexPath.section && 0 == indexPath.item){
    //        return NO;
    //    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
        didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView
        didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //    YWSubscribeCell *cell = (YWSubscribeCell *)[collectionView
    //    cellForItemAtIndexPath:indexPath];
    ////    cell.contentView.backgroundColor = [UIColor clearColor];
    //    cell.titleLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.optionItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JXToolBarOptionItemView *cell = (JXToolBarOptionItemView *)[collectionView
            dequeueReusableCellWithReuseIdentifier:[[JXToolBarOptionItemView class] description]
                                      forIndexPath:indexPath];
    if ([self.optionItems count] > indexPath.row) {
        cell.item = self.optionItems[indexPath.row];
    }
    return cell;
}

#pragma mark - getter

- (NSMutableArray *)optionItems {
    if (!_optionItems) {
        _optionItems = [NSMutableArray array];
    }
    return _optionItems;
}

@end
