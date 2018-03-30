//
//  JXShowView.m
//

#import "JXActionView.h"

@implementation JXActionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup {
    self.mainTableView = [[UITableView alloc]
            initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [self addSubview:self.mainTableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellId];
    }
    NSTextCheckingResult *result = [self.dataSource objectAtIndex:indexPath.row];
    NSString *text = nil;
    if (result.resultType == NSTextCheckingTypePhoneNumber) {
        text = result.phoneNumber;
    } else if (result.resultType == NSTextCheckingTypeLink) {
        text = result.URL.absoluteString;
    }
    cell.textLabel.text = text;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSTextCheckingResult *result = [self.dataSource objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectedItem:)]) {
        [self.delegate didSelectedItem:result];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSTextCheckingResult *result = [self.dataSource objectAtIndex:indexPath.row];
    NSString *text = nil;
    if (result.resultType == NSTextCheckingTypePhoneNumber) {
        text = result.phoneNumber;
    } else if (result.resultType == NSTextCheckingTypeLink) {
        text = result.URL.absoluteString;
    }
    CGSize size = [text boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingUsesFontLeading
                                    attributes:@{
                                        NSFontAttributeName : [UIFont systemFontOfSize:16]
                                    }
                                       context:nil]
                          .size;

    return 60 > size.height ? 60 : size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
@end
