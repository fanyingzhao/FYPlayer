//
//  VideoDownloadManager.h
//  FYPlayer
//
//  Created by fan on 16/7/21.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JFURLConnection;
@interface VideoDownloadManager : NSObject

@property (nonatomic, strong) NSMutableArray* downloadingList;
@property (nonatomic, strong) NSMutableArray* downloadFinishedList;


+ (instancetype)sharedDownloadManager;

- (JFURLConnection*)addDownloadingTask:(NSURL*)url;
- (JFURLConnection*)addDownloadFinishedTask:(NSURL*)url;

- (BOOL)checkVideoIsDownloadFinish:(NSURL*)url;
- (NSURL*)getLocalVideoUrl:(NSURL*)url;

- (void)save;

@end
