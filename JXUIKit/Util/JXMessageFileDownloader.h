//
//  JXMessageFileDownloader.h
//

#import "JXMessage.h"
#import <CoreGraphics/CGBase.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DownloadStatus) {
    kDownloadStatusUndownload,
    kDownloadStatusDownloading,
    kDownloadStatusDownloadFinished,
    kDownloadStatusDownloadFailed
};

@interface JXDownloadStatus : NSObject
@property(nonatomic, assign) DownloadStatus status;
@property(nonatomic, assign) CGFloat progress;
@end

@protocol JXMessageFileDownloaderDelegate<NSObject>

- (void)didMessage:(NSString *)messageID updateProgress:(float)progress;

- (void)messageFileDownloadSuccesed:(NSString *)messageID;

- (void)messageFileDownloadFailed:(NSString *)messageID;

@end

@interface JXMessageFileDownloader : NSObject

/**
 *  下载message对象对应的文件
 * @param
 * @return
 */
+ (void)downloadFileForMessage:(JXMessage *)message;

/**
 *  判断对应messageID 下的文件是否正在下载
 * @param
 * @return
 */
+ (BOOL)isDownloadingMessage:(NSString *)messageID;

/**
 *  添加下载观察者
 * @param
 * @return
 */
+ (void)addDownloadStatusObserver:(id<JXMessageFileDownloaderDelegate>)observer;

/**
 *  移除下载观察者
 * @param
 * @return
 */
+ (void)removeDownloadStatusObserver:(id<JXMessageFileDownloaderDelegate>)observer;

@end
