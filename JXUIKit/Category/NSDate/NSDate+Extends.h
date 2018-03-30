//
//  NSDate+Extends.h
//

#import <Foundation/Foundation.h>

#define SecIn_MINUTE 60
#define SecIn_HOUR 3600
#define SecIn_DAY 86400
#define SecIn_WEEK 604800
#define SecIn_YEAR 31556926

@interface NSDate (Extends)
+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;
+ (NSString *)formattedTimeFromTimeInterval:(long long)time;
- (NSString *)formattedTime;
@end
