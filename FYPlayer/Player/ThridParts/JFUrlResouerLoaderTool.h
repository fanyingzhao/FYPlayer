//
//  JFUrlResouerLoaderTool.h
//  Interactive
//
//  Created by fan on 16/7/18.
//  Copyright © 2016年 Abner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "JFURLConnection.h"
#import "VideoDownloadManager.h"

@protocol JFUrlResouerLoaderToolDelegate <NSObject>
- (void)videoPlayerDownloadFailure:(NSError*)error;

@end

@interface JFUrlResouerLoaderTool : NSObject<AVAssetResourceLoaderDelegate>

- (instancetype)initWithUrl:(NSURL*)url;

@property (nonatomic, weak) id<JFUrlResouerLoaderToolDelegate> delegate;

@property (nonatomic, strong, readonly) JFURLConnection* connection;
/**
 *  是否在播放时下载,边下边播
 */
@property (nonatomic, assign) BOOL shouldDownloadWhilePlaying;

@property (nonatomic, strong, readonly) NSURL* url;

- (void)stopCache;
@end
