//
//  JFUrlResouerLoaderTool.m
//  Interactive
//
//  Created by fan on 16/7/18.
//  Copyright © 2016年 Abner. All rights reserved.
//

#import "JFUrlResouerLoaderTool.h"
#import "JFURLConnection.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface JFUrlResouerLoaderTool ()<JFURLConnectionDelegate> {
    NSMutableArray* _loadingList;
    BOOL _drag;
    BOOL _ready;
}
@property (nonatomic, strong) JFURLConnection* connection;

@end

@implementation JFUrlResouerLoaderTool

- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        _loadingList = [NSMutableArray array];
        
        [self addNotificationMonitor];
    }
    return self;
}

- (void)dealloc {
    [self removeNotificationMonitor];
    if (!self.shouldDownloadWhilePlaying) {
        NSLog(@"取消了一个");
        [self.connection cancel];
        [[NSFileManager defaultManager] removeItemAtPath:self.connection.videoPath error:nil];
    }

    self.connection = nil;
}

#pragma mark - notificaiton
- (void)dragEvent:(NSNotification*)noti {
    _drag = YES;
}

- (void)addNotificationMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragEvent:) name:@"seekToTimeNotification" object:nil];
}

- (void)removeNotificationMonitor {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - tools
- (void)processPendingRequests {
    @autoreleasepool {
        NSMutableArray* tempList = [NSMutableArray array];
        
        NSInteger i = 0;
        for (AVAssetResourceLoadingRequest* loadingRequest in _loadingList.copy) {
            if (loadingRequest.isCancelled) {
                [tempList addObject:loadingRequest];
                continue;
            }
            i ++;
            loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
            loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(@"video/mp4"), NULL));
            loadingRequest.contentInformationRequest.contentLength = self.connection.videoLength;

            if (!self.connection.isDownloadFinish) {
                // 如果想要的数据还没有下载，跳过
                if (![self.connection checkLocalDataIsExistWithOffset:loadingRequest.dataRequest.currentOffset]) {
                    continue;
                }
            }

            NSUInteger startOffset = loadingRequest.dataRequest.currentOffset;
            [self.connection.readFileHandle seekToFileOffset:startOffset];
            NSData* data = [self.connection.readFileHandle readDataOfLength:MIN(MIN(loadingRequest.dataRequest.requestedLength, self.connection.currentOffset - startOffset), 1024 * 1024 * 10)];
            [loadingRequest.dataRequest respondWithData:data];
            
            if (self.connection.currentOffset >= loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength) {
                [tempList addObject:loadingRequest];
                [loadingRequest finishLoading];
            }
        }
        
        [_loadingList removeObjectsInArray:tempList];
    }
}

- (void)stopCache {
    [self.connection cancel];
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    [_loadingList addObject:loadingRequest];
    
//    NSLog(@"开始缓存，范围：offset -- %.2fKB, length -- %.2fKB",(CGFloat)loadingRequest.dataRequest.currentOffset / 1024 ,(CGFloat)loadingRequest.dataRequest.requestedLength / 1024 );
    
    // 本地是否存在缓存，如果没有存在，则创建
    if (!_ready) {
        _ready = YES;
        [_connection requestWithOffset:0];
    }else if (_drag) {
        [self.connection requestWithOffset:loadingRequest.dataRequest.currentOffset];
        _drag = NO;
    }
    
    if (self.connection.isDownloadFinish) {
        [self processPendingRequests];
    }
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
}

#pragma mark - JFURLConnectionDelegate
- (void)connectionDidReceiveVideoData:(JFURLConnection *)connection {
    [self processPendingRequests];
}

- (void)connectionDidFinishDownload:(JFURLConnection *)connection {
}

- (void)connectionDidFailure:(JFURLConnection *)connection error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(videoPlayerDownloadFailure:)]) {
        [self.delegate videoPlayerDownloadFailure:error];
    }
}

#pragma mark - setter
- (void)setShouldDownloadWhilePlaying:(BOOL)shouldDownloadWhilePlaying {
    _shouldDownloadWhilePlaying = shouldDownloadWhilePlaying;
    if (shouldDownloadWhilePlaying) {
        self.connection = [[VideoDownloadManager sharedDownloadManager] addDownloadingTask:self.url];
        self.connection.delegate = self;
    }
}


#pragma mark - getter

@end
