//
//  JXMessage+Extends.h
//

#import "JXMessage.h"

@interface JXMessage (Extends)

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, copy) NSString *failedImageName;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) NSInteger indexInTableView;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) BOOL isMediaPlaying;

- (BOOL)isSender;

- (NSString *)textWithEmoji;

- (NSAttributedString *)textWithWechatEmoji:(NSString *)text;

- (UIImage *)defaultImage;

- (CGSize)thumbnailImageSize;

- (NSString *)fileSizeDes;

- (NSString *)durationDes;

- (NSMutableAttributedString *)attributedText;

- (NSArray<NSTextCheckingResult *> *)urlMatches;

- (BOOL)hasHTMLTag;

@end
