//
//  JXMessageTimeCell.m
//

#import "JXMessageTimeCell.h"

CGFloat const JXMessageTimeCellPadding = 5;

@interface JXMessageTimeCell ()

@property(nonatomic) UILabel *titleLabel;

@end

@implementation JXMessageTimeCell

+ (void)initialize {
    // UIAppearance Proxy Defaults
    JXMessageTimeCell *cell = [self appearance];
    cell.titleLabelColor = [UIColor whiteColor];
    cell.titleLabelFont = [UIFont systemFontOfSize:12];
    cell.titleLabelCornerRadious = cell.titleLabelFont.lineHeight * 0.35;
    cell.titleLabelBkgColor = [UIColor colorWithWhite:0.8 alpha:1];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self _setupSubview];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.layer.cornerRadius = _titleLabelCornerRadious;
    _titleLabel.clipsToBounds = YES;
    _titleLabel.backgroundColor = _titleLabelBkgColor;
}

#pragma mark - setup subviews

- (void)_setupSubview {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = _titleLabelColor;
    _titleLabel.font = _titleLabelFont;
    [self.contentView addSubview:_titleLabel];

    [self _setupTitleLabelConstraints];
}

#pragma mark - Setup Constraints

- (void)_setupTitleLabelConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:JXMessageTimeCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-JXMessageTimeCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
}

#pragma mark - setter

- (void)setTitle:(NSString *)title {
    _title = [NSString stringWithFormat:@" %@ ", title];
    _titleLabel.text = _title;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    _titleLabel.font = _titleLabelFont;
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor {
    _titleLabelColor = titleLabelColor;
    _titleLabel.textColor = _titleLabelColor;
}

- (void)setTitleLabelBkgColor:(UIColor *)titleLabelBkgColor {
    _titleLabelBkgColor = titleLabelBkgColor;
    _titleLabel.backgroundColor = titleLabelBkgColor;
}

- (void)setTitleLabelCornerRadious:(CGFloat)titleLabelCornerRadious {
    _titleLabelCornerRadious = titleLabelCornerRadious;
    _titleLabel.layer.cornerRadius = titleLabelCornerRadious;
}

#pragma mark - public

+ (NSString *)cellIdentifier {
    return @"MessageTimeCell";
}

@end
