//
//  JFURLConnection.m
//  Interactive
//
//  Created by fan on 16/7/18.
//  Copyright © 2016年 Abner. All rights reserved.
//

#import "JFURLConnection.h"
#import "NSString+FYAdd.h"
#import "VideoDownloadManager.h"
#import "NSString+FYAdd.h"
#import <UIKit/UIKit.h>

@interface ContainObject : NSObject <NSCoding>

@property (nonatomic, assign) NSRange range;
@end
@implementation ContainObject

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithRange:_range] forKey:@"range"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
    }
    return self;
}

@end

#define kOffset             @"offset"
#define kUrl                @"url"
#define kVideoName          @"videoName"
#define kVideoLength        @"videoLength"
#define kCurrentOffset      @"currentOfffset"
#define kDownloadLength     @"downloadLength"
#define kDownloadFinish     @"downloadFinish"
#define kDownRangeList      @"downloadRangeList"


@interface JFURLConnection() <NSURLConnectionDataDelegate> {
    NSMutableArray* _downRangeList;     // 已经下载的视频范围
    
    ContainObject* _currentValue;
    
    NSDate* _date;
    NSUInteger _downloadSize;
    NSTimer* _autoSaveTimer;
}
@property (nonatomic, copy) NSString* videoPath;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, assign) NSUInteger videoLength;
@property (nonatomic, assign) NSUInteger currentOffset;
@property (nonatomic, assign) NSUInteger downloadLength;
@property (nonatomic, strong) NSFileHandle* writeFileHandle;
@property (nonatomic, strong) NSFileHandle* readFileHandle;
@property (nonatomic, assign, getter=isDownloadFinish) BOOL downloadFinish;

@end

@implementation JFURLConnection

- (instancetype)init {
    if (self = [super init]) {
        _videoLength = NSUIntegerMax;
        _path = [JFURLConnection videoCacheDefaultPath];

        if (![[NSFileManager defaultManager] fileExistsAtPath:_path]) {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:_path withIntermediateDirectories:NO attributes:nil error:nil]) {
                NSLog(@"创建缓存目录失败");
            }
        }
        
        _queue = [[NSOperationQueue alloc] init];
        _downRangeList = [NSMutableArray array];
        [self addNotificationMonitor];
        [self addAutoSaveTimer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _path = [JFURLConnection videoCacheDefaultPath];
        _url = [aDecoder decodeObjectForKey:kUrl];
        _offset = [[aDecoder decodeObjectForKey:kOffset] unsignedIntValue];
        _videoName = [aDecoder decodeObjectForKey:kVideoName];
        _videoLength = [[aDecoder decodeObjectForKey:kVideoLength] unsignedIntValue];
        _currentOffset = [[aDecoder decodeObjectForKey:kCurrentOffset] unsignedIntValue];
        _downloadLength = [[aDecoder decodeObjectForKey:kDownloadLength] unsignedIntValue];
        _downloadFinish = [[aDecoder decodeObjectForKey:kDownloadFinish] boolValue];
        _downRangeList = [aDecoder decodeObjectForKey:kDownRangeList];
        
        _videoPath = [JFURLConnection getLocalVideoPath:_url];
        _writeFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.videoPath];
        _readFileHandle = [NSFileHandle fileHandleForReadingAtPath:self.videoPath];
        
        _queue = [[NSOperationQueue alloc] init];
        
        [self addNotificationMonitor];
        [self addAutoSaveTimer];
        
        [self downloadTarget];
    }
    return self;
}

- (void)dealloc {
    [self removeNotificationMonitor];
    [self.writeFileHandle closeFile];
    [self.readFileHandle closeFile];
}

#pragma mark - notification
- (void)addNotificationMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminater:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)removeNotificationMonitor {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillTerminater:(NSNotification*)noti {
    [self saveDownloadProgress];
}

#pragma mark - timer
- (void)addAutoSaveTimer {
    _autoSaveTimer = [NSTimer timerWithTimeInterval:5.f target:self selector:@selector(saveDownloadProgress:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_autoSaveTimer forMode:NSRunLoopCommonModes];
    [_autoSaveTimer setFireDate:[NSDate distantFuture]];
}

- (void)removeTimer {
    [_autoSaveTimer invalidate];
    _autoSaveTimer = nil;
}

/**
 *  每五秒自动保存一次下载进度
 */
- (void)saveDownloadProgress:(NSTimer*)timer {
    [self saveDownloadProgress];
}

#pragma mark - encode
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:kUrl];
    [aCoder encodeObject:@(_offset) forKey:kOffset];
    [aCoder encodeObject:_videoName forKey:kVideoName];
    [aCoder encodeObject:@(_videoLength) forKey:kVideoLength];
    [aCoder encodeObject:@(_currentOffset) forKey:kCurrentOffset];
    [aCoder encodeObject:@(_downloadLength) forKey:kDownloadLength];
    [aCoder encodeObject:@(_downloadFinish) forKey:kDownloadFinish];
    [aCoder encodeObject:_downRangeList forKey:kDownRangeList];
}


#pragma mark - tools
- (void)saveDownloadProgress {
    [[VideoDownloadManager sharedDownloadManager] save];
}

+ (NSString*)videoCacheDefaultPath {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"videoCache"];
}

+ (NSString*)fileName:(NSURL*)url {
    return [[url lastPathComponent] md5EncoderFilename];
}

+ (NSString*)getLocalVideoPath:(NSURL*)url {
    return [[JFURLConnection videoCacheDefaultPath] stringByAppendingPathComponent:[self fileName:url]];
}

+ (BOOL)checkVideoLocalIsExists:(NSURL*)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[JFURLConnection getLocalVideoPath:url]];
}
/**
 *  检查请求的数据在本地是否存在
 *
 *  @param offset 偏移量
 *
 *  @return 是否存在
 */
- (BOOL)checkLoclIsExist:(NSUInteger)offset {
    for (ContainObject* value in _downRangeList) {
        NSRange range = value.range;
        if (offset > range.location && offset < range.length) {
            return YES;
        }
    }
    
    return NO;
}

- (NSUInteger)getDownloadStartWithOffset:(NSUInteger)offset {
    NSUInteger targetPosition = offset;
    for (ContainObject* value in _downRangeList) {
        NSRange range = value.range;
        if (offset > range.location && offset < range.location) {
            targetPosition = MAX(targetPosition, range.location);
        }
    }
    return targetPosition;
}

/**
 *  通过偏移量，查询当前的所有下载，计算出一个最大的下载值
 *
 *  @param offset 偏移量
 *
 *  @return 下载到的位置
 */
- (NSUInteger)getTargetMaxDownloadPositionWithOffset:(NSUInteger)offset {
    NSUInteger targetPosition = self.videoLength;
    for (ContainObject* value in _downRangeList) {
        NSRange range = value.range;
        if (range.location > offset) {
            targetPosition = MIN(range.location, targetPosition);
        }
    }
    return targetPosition;
}

- (NSMutableArray*)updateDownloadList:(NSMutableArray*)list {
    if (list.count == 1) {
        return list;
    }
    
    NSMutableArray* tempList = [list mutableCopy];
    for (NSValue* value in tempList) {
        NSRange range = [value rangeValue];
        for (NSValue* tempValue in tempList) {
            NSRange tempRange = [tempValue rangeValue];
            if ([value isEqual:tempValue]) {
                continue;
            }
            
            if (range.length == tempRange.location || range.length + 1 == tempRange.location) {
                // 合并
                NSRange resRange = NSMakeRange(range.location, tempRange.length);
                [list removeObject:value];
                [list removeObject:tempValue];
                [list addObject:[NSValue valueWithRange:resRange]];
                return list = [self updateDownloadList:[list mutableCopy]];
            }else if (range.location == tempRange.length - 1) {
                NSRange resRange = NSMakeRange(tempRange.location, range.length);
                [list removeObject:value];
                [list removeObject:tempValue];
                [list addObject:[NSValue valueWithRange:resRange]];
                return list = [self updateDownloadList:[list mutableCopy]];
            }
        }
    }
    
    return tempList;
}

- (NSRange)getTargetDownloadRange:(NSMutableArray*)list {
    if (list.count > 1) {
        NSRange firstRange = ((ContainObject*)list[0]).range;
        NSRange secondRange = ((ContainObject*)list[1]).range;
        return NSMakeRange(firstRange.length + 1, secondRange.location - 1);
    }else if (!list.count) {
        return NSMakeRange(0, 0);
    }
    else {
        NSRange firstRange = ((ContainObject*)list[0]).range;
        if (firstRange.location == 0 && firstRange.length == self.videoLength) {
            return NSMakeRange(0, 0);
        }
        return NSMakeRange(firstRange.length + 1, self.videoLength);
    }
}

- (BOOL)checkLocalDataIsExistWithOffset:(NSUInteger)offset {
    if (!_downRangeList.count) {
        return YES;
    }
    
    if (_downloadFinish) {
        return YES;
    }
    if (offset > _currentValue.range.length) {
        return NO;
    }
    
    return YES;
}

- (BOOL)downloadTarget {
    // 先将相邻的下载区间合并
    NSMutableArray* temp = [NSMutableArray array];
    for (ContainObject* obj in _downRangeList) {
        NSValue* value = [NSValue valueWithRange:obj.range];
        [temp addObject:value];
    }
    
    temp = [self updateDownloadList:temp];
    
    [_downRangeList removeAllObjects];
    for (NSValue* value in temp) {
        ContainObject* obj = [ContainObject new];
        obj.range = [value rangeValue];
        [_downRangeList addObject:obj];
    }
    
    [_downRangeList sortUsingComparator:^NSComparisonResult(ContainObject*  _Nonnull obj1, ContainObject*  _Nonnull obj2) {
        NSRange range = obj1.range;
        NSRange nextRange = obj2.range;
        if (range.location > nextRange.location) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    // 找出需要下载的下一段
    NSRange range = [self getTargetDownloadRange:_downRangeList];
    if ((!range.location && !range.length) || range.location > self.videoLength) {
        // 防止出现无限下载的情况
        return YES;
    }else if (range.location && range.length) {
        // 开始下载
        [self requestWithOffset:range.location];
    }
    
    return NO;
}

#pragma mark - delegate
- (void)delegateReceiveData {
    if ([self.delegate respondsToSelector:@selector(connectionDidReceiveVideoData:)]) {
        [self.delegate connectionDidReceiveVideoData:self];
    }
}

#pragma mark - funcs
- (void)requestWithOffset:(NSUInteger)offset {
    if (self.isDownloadFinish || (!offset && self.downloadLength)) {    // 排除断点下载时外部取消的情况
        return;
    }
    
    NSUInteger startOffset = [self getDownloadStartWithOffset:offset];
    
    //    NSLog(@"请求数据位置:position -- %lu   下载数据位置 -- %lu",offset / 1024 / 1024, startOffset / 1024 / 1024);
    
    if ([self checkLoclIsExist:offset]) {
        // 本地已经有请求的数据
        [self delegateReceiveData];
    }
    
    [self requestUrlWithStartOffset:startOffset endOffset:[self getTargetMaxDownloadPositionWithOffset:offset]];
}

- (void)requestUrlWithStartOffset:(NSUInteger)offset endOffset:(NSUInteger)endOffset {
    [self.connection cancel];
    
    self.offset = offset;
    _currentOffset = offset;

    NSURLComponents* tempUrl = [NSURLComponents componentsWithURL:self.url resolvingAgainstBaseURL:NO];
    tempUrl.scheme = @"http";
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[tempUrl URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    if (offset > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)offset, (unsigned long)endOffset] forHTTPHeaderField:@"Range"];
        NSLog(@"start -- %ld    endOffset -- %ld",offset / 1024 / 1024, endOffset / 1024 / 1024);
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:_queue];
    [self.connection start];
}

- (void)cancel {
    [self.connection cancel];
}

- (void)stop {
    [self.connection cancel];
    self.offset = self.currentOffset;
    [self saveDownloadProgress];
}

- (void)start {
    [self requestWithOffset:self.offset];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    if (_offset == 0) {
        if (response.statusCode == 200) self.videoLength = response.expectedContentLength;
        else self.videoLength = 0;
    }
    
    if (self.videoLength) {
        @autoreleasepool {
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
                // 判断文件大小是否相等，如果不相等，则删除
                NSUInteger size = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.videoPath error:nil] fileSize];
                if (size != self.videoLength) {
                    [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
                    
                    NSMutableData* data = [NSMutableData dataWithLength:self.videoLength];
                    if (![[NSFileManager defaultManager] createFileAtPath:self.videoPath contents:data attributes:nil]) {
                        NSLog(@"创建失败,空间不足处理,提示用户空间不足");
                    }
                }else {
                    // 判断是否已经下载完毕

                }
            }else {
                NSMutableData* data = [NSMutableData dataWithLength:self.videoLength];
                if (![[NSFileManager defaultManager] createFileAtPath:self.videoPath contents:data attributes:nil]) {
                    NSLog(@"创建失败,空间不足处理,提示用户空间不足");
                }
            }
        };
    }
    _writeFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.videoPath];
    _readFileHandle = [NSFileHandle fileHandleForReadingAtPath:self.videoPath];
    
    _currentValue = [ContainObject new];
    _currentValue.range = NSMakeRange(self.offset, self.currentOffset);
    [_downRangeList addObject:_currentValue];
    _date = [NSDate date];
    [_autoSaveTimer setFireDate:_date];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_writeFileHandle seekToFileOffset:_currentOffset];
    [_writeFileHandle writeData:data];
    _currentOffset += data.length;
    _downloadLength += data.length;
    _currentValue.range = NSMakeRange(self.offset, self.currentOffset);
    _downloadSize += data.length;
    
    {
        static NSUInteger tempData = -1;
        if (tempData / 1024 / 1024 != _currentOffset / 1024 / 1024) {
            //        NSLog(@"startOffset -- %lu    endOffset -- %lu",_offset / 1024 / 1024,_currentOffset / 1024 / 1024);
            tempData = _currentOffset;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(connectionDidReceiveVideoData:)]) {
        [self.delegate connectionDidReceiveVideoData:self];
    }
    
    // 一秒回调一次
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_date];
    if (interval > 1.f) {
        NSUInteger speed = _downloadSize / interval;
        if (self.progressBlock) {
            self.progressBlock(self.videoName, self.videoLength, speed, self.downloadLength);
        }
        
        _downloadSize = 0;
        _date = [NSDate date];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self downloadTarget]) {
        self.downloadFinish = YES;
        NSLog(@"全部下载完毕");
        [[VideoDownloadManager sharedDownloadManager] addDownloadFinishedTask:self.url];
        
        if ([self.delegate respondsToSelector:@selector(connectionDidFinishDownload:)]) {
            [self.delegate connectionDidFinishDownload:self];
        }
        
        if (self.finishBlock) {
            self.finishBlock(self.videoName, self.videoPath, self.videoLength, nil);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"失败:%@",error);
    if ([self.delegate respondsToSelector:@selector(connectionDidFailure:error:)]) {
        [self.delegate connectionDidFailure:self error:error];
    }
    
    if (self.finishBlock) {
        [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
        self.finishBlock(self.videoName, nil, self.videoLength, error);
    }
}

#pragma mark - setter
- (void)setUrl:(NSURL *)url {
    _url = url;
    _videoPath = [JFURLConnection getLocalVideoPath:_url];
}

#pragma mark - getter
- (NSString *)videoName {
    if (!_videoName) {
        _videoName = [JFURLConnection fileName:self.url];
    }
    return _videoName;
}

@end
