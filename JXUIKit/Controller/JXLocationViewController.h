//
//  JXLocationViewController.h
//

#import "JXBaseViewController.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^JXLocationResponseBlock)(NSString *locationStr, CLLocation *location);

@interface JXLocationViewController : JXBaseViewController

@property(nonatomic, strong) NSString *locationDescribe;
@property(nonatomic, copy) JXLocationResponseBlock locationBlock;

- (instancetype)initWithLoction:(CLLocation *)location;

@end
