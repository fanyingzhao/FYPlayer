//
//  VideoDownloadManager.m
//  FYPlayer
//
//  Created by fan on 16/7/21.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "VideoDownloadManager.h"
#import "JFURLConnection.h"

#define kDownloadingList        @"downloadingList"
#define kDownloadFinishedList   @"downloadFinishedList"

@interface VideoDownloadManager () {
    NSString* _downloadingPath;
    NSString* _downloadFinishedPath;
}

@end

@implementation VideoDownloadManager

+ (instancetype)sharedDownloadManager {
    static VideoDownloadManager* videoDownloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoDownloadManager = [[VideoDownloadManager alloc] init];
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        videoDownloadManager->_downloadingPath = [path stringByAppendingPathComponent:@"downloading.archiver"];
        videoDownloadManager->_downloadFinishedPath = [path stringByAppendingString:@"downloadFinished.archiver"];
    });
    return videoDownloadManager;
}

- (JFURLConnection*)addDownloadingTask:(NSURL *)url {
    __block JFURLConnection* connection = nil;
    __block BOOL exists = NO;
    [self.downloadingList enumerateObjectsUsingBlock:^(JFURLConnection*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[url absoluteString] isEqualToString:[obj.url absoluteString]]) {
            connection = obj;
            exists = YES;
            *stop = YES;
        }
    }];
    
    if (exists) {
        return connection;
    }else {
        connection = [[JFURLConnection alloc] init];
        connection.url = url;
        [self.downloadingList addObject:connection];
    }
    
    return connection;
}

- (JFURLConnection*)addDownloadFinishedTask:(NSURL *)url {
    __block JFURLConnection* connection = nil;
    [self.downloadingList enumerateObjectsUsingBlock:^(JFURLConnection*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[url absoluteString] isEqualToString:[obj.url absoluteString]]) {
            connection = obj;
            *stop = YES;
        }
    }];
    if (connection) [self.downloadingList removeObject:connection];
    
    __block BOOL exists = NO;
    [self.downloadFinishedList enumerateObjectsUsingBlock:^(JFURLConnection*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[url absoluteString] isEqualToString:[obj.url absoluteString]]) {
            exists = YES;
            *stop = YES;
        }
    }];
    
    if (!exists) [self.downloadFinishedList addObject:connection];
    return connection;
}

- (void)save {
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.downloadingList forKey:kDownloadingList];
    [archiver finishEncoding];
    [data writeToFile:_downloadingPath atomically:YES];
    
    NSMutableData* data1 = [[NSMutableData alloc] init];
    NSKeyedArchiver * archiver1 = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data1];
    [archiver1 encodeObject:self.downloadFinishedList forKey:kDownloadFinishedList];
    [archiver1 finishEncoding];
    [data1 writeToFile:_downloadFinishedPath atomically:YES];
}

- (BOOL)checkVideoIsDownloadFinish:(NSURL*)url {
    __block BOOL exists = NO;
    [self.downloadFinishedList enumerateObjectsUsingBlock:^(JFURLConnection*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[url absoluteString] isEqualToString:[obj.url absoluteString]]) {
            exists = YES;
            *stop = YES;
        }
    }];
    
    return exists;
}

- (NSURL *)getLocalVideoUrl:(NSURL *)url {
    return [NSURL fileURLWithPath:[JFURLConnection getLocalVideoPath:url]];
}

#pragma mark - getter
- (NSMutableArray *)downloadingList {
    if (!_downloadingList) {
        NSData* content = [NSData dataWithContentsOfFile:_downloadingPath];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:content];
        _downloadingList = [unarchiver decodeObjectForKey:kDownloadingList];
        if (!_downloadingList) {
            _downloadingList = [NSMutableArray array];
        }
    }
    return _downloadingList;
}

- (NSMutableArray *)downloadFinishedList {
    if (!_downloadFinishedList) {
        NSData* content = [NSData dataWithContentsOfFile:_downloadFinishedPath];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:content];
        _downloadFinishedList = [unarchiver decodeObjectForKey:kDownloadFinishedList];
        if (!_downloadFinishedList) {
            _downloadFinishedList = [NSMutableArray array];
        }
    }
    return _downloadFinishedList;
}

@end
