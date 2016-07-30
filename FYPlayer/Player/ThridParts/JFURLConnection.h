//
//  JFURLConnection.h
//  Interactive
//
//  Created by fan on 16/7/18.
//  Copyright © 2016年 Abner. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JFURLConnection;
@protocol JFURLConnectionDelegate <NSObject>
- (void)connectionDidReceiveVideoData:(JFURLConnection*)connection;
- (void)connectionDidFinishDownload:(JFURLConnection*)connection;
- (void)connectionDidFailure:(JFURLConnection*)connection error:(NSError*)error;

@end


typedef void(^FYVideoDownloadProgress)(NSString* fileName, NSUInteger fileSize, NSUInteger speed, NSUInteger downloadSize);
typedef void(^FYVideoDownloadFinish)(NSString* fileName, NSString* filePath, NSUInteger fileSize, NSError* error);
@interface JFURLConnection : NSObject<NSCoding>

@property (nonatomic, strong) NSOperationQueue* queue;
/**
 *  缓存的目录
 */
@property (nonatomic, copy) NSString* path;
/**
 *  最新开始下载的偏移
 */
@property (nonatomic, assign) NSUInteger offset;
/**
 *  当前视频的url
 */
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, weak) id<JFURLConnectionDelegate> delegate;
/**
 *  视频存储在本地的路径
 */
@property (nonatomic, copy, readonly) NSString* videoPath;
@property (nonatomic, strong, readonly) NSURLConnection* connection;
/**
 *  视频的名字，默认为视频的url最后路径md5编码
 */
@property (nonatomic, copy) NSString* videoName;
/**
 *  视频的总长度
 */
@property (nonatomic, assign, readonly) NSUInteger videoLength;
/**
 *  从一段新的下载开始，下载的总长度
 */
@property (nonatomic, assign, readonly) NSUInteger currentOffset;
/**
 *  下载的总长度
 */
@property (nonatomic, assign, readonly) NSUInteger downloadLength;
/**
 *  写文件的指针
 */
@property (nonatomic, strong, readonly) NSFileHandle* writeFileHandle;
/**
 *  读文件的指针
 */
@property (nonatomic, strong, readonly) NSFileHandle* readFileHandle;
/**
 *  当前是否下载完毕
 */
@property (nonatomic, assign, readonly, getter=isDownloadFinish) BOOL downloadFinish;


@property (nonatomic, copy) FYVideoDownloadProgress progressBlock;
@property (nonatomic, copy) FYVideoDownloadFinish finishBlock;

+ (NSString*)getLocalVideoPath:(NSURL*)url;
+ (BOOL)checkVideoLocalIsExists:(NSURL*)url;
- (void)requestWithOffset:(NSUInteger)offset;
- (BOOL)checkLocalDataIsExistWithOffset:(NSUInteger)offset;

- (void)cancel;
- (void)stop;
- (void)start;

@end
