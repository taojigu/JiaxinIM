//
//  WKVideoConverter.h
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JXVideoConverter;
@protocol WKVideoConverterDelegate<NSObject>

- (void)videoConverter:(JXVideoConverter *)converter progress:(CGFloat)progress;
- (void)videoConverterFinishConvert:(JXVideoConverter *)converter;

@end

typedef void (^block)(void);

@interface JXVideoConverter : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, weak) id<WKVideoConverterDelegate> delegate;

- (void)convertVideoToImagesWithURL:(NSURL *)url
                        finishBlock:(void (^)(id))finishBlock;    //转成CGImage

- (void)convertVideoFirstFrameWithURL:(NSURL *)url
                          finishBlock:(void (^)(id))finishBlock;    //转成CGImage

- (void)convertVideoUIImagesWithURL:(NSURL *)url
                        finishBlock:(void (^)(id images,
                                              NSTimeInterval duration))finishBlock;    // images

- (void)convertVideoToGifImageWithURL:(NSURL *)url
                       destinationUrl:(NSURL *)destinationUrl
                          finishBlock:(void (^)(void))finishBlock;

+ (CGImageRef)convertSamepleBufferRefToCGImage:(CMSampleBufferRef)sampleBufferRef;

+ (UIImage *)convertSampleBufferRefToUIImage:(CMSampleBufferRef)sampleBufferRef;

+ (BOOL)convertMovToMP4:(NSURL *)url ToURL:(NSURL *)toUrl;

@end
