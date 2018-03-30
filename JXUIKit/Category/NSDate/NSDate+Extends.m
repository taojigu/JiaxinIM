//
//  NSDate+Extends.m
//

#import "NSDate+Extends.h"
#import "NSDateFormatter+Extends.h"

@implementation NSDate (Extends)

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond {
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    if (timeIntervalInMilliSecond > 140000000000) {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return ret;
}

+ (NSString *)formattedTimeFromTimeInterval:(long long)time {
    return [[NSDate dateWithTimeIntervalInMilliSecondSince1970:time] formattedTime];
}

/*标准时间日期描述*/
- (NSString *)formattedTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8, 2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5, 2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0, 4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components];    //今天 0点时间

    NSInteger hour = [self hoursAfterDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";

    // hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours =
            [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;

    if (!hasAMPM) {    // 24小时制
        if (hour <= 24 && hour >= 0) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
        } else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"M-d HH:mm"];
        } else {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"M-d HH:mm"];
        }
    } else {
        if (hour >= 0 && hour <= 6) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"aa hh:mm "];
        } else if (hour > 6 && hour <= 11) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"aa hh:mm"];
        } else if (hour > 11 && hour <= 17) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"aa hh:mm"];
        } else if (hour > 17 && hour <= 24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"aa hh:mm"];
        } else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"M-d HH:mm"];
        } else {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"M-d HH:mm"];
        }
    }
    ret = [dateFormatter stringFromDate:self];
    return ret;
}

#pragma mark -
#pragma mark - private method

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / SecIn_HOUR);
}

@end
