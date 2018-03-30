//
//  NSDateFormatter+Extends.h
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Extends)

+ (id)dateFormatter;
+ (id)dateFormatterWithFormat:(NSString *)dateFormat;

/**
 *  Default date formatter is yyyy-MM-dd HH:mm:ss
 * @param
 * @return
 */
+ (id)defaultDateFormatter;

@end
