//
//  FYPlayer.h
//  FYPlayer
//
//  Created by fan on 16/7/20.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoDrawModel.h"
#import "JFUrlResouerLoaderTool.h"

@class FYPlayer;
@protocol FYPlayerDelegate <NSObject>
@optional
- (void)videoPlayerReadyToPlayVideo:(FYPlayer*)player;
- (void)videoPlayer:(FYPlayer*)player didFailureWithError:(NSError*)error;
- (void)videoPlayerShowLoadingView:(FYPlayer*)player;
- (void)videoPlayerHiddenLoadingView:(FYPlayer*)player;
- (void)videoPlayerDidReachEnd:(FYPlayer*)player;
- (void)videoPlayer:(FYPlayer*)player periodicCallback:(CGFloat)time;

@end

@interface FYPlayer : NSObject<VideoDrawModelDelegate>

@property (nonatomic, strong, readonly) AVPlayer* player;
@property (nonatomic, strong, readonly) AVPlayerItem* item;
/**
 *  当前是否播放
 */
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
/**
 *  当前播放视频源的url
 */
@property (nonatomic, strong, readonly) NSURL* url;
/**
 *  视频的总长度
 */
@property (nonatomic, assign, readonly) CGFloat duration;
/**
 *  当前播放时间
 */
@property (nonatomic, assign, readonly) CGFloat currentTime;
/**
 *  是否是全景视频
 */
@property (nonatomic, assign, readonly, getter=isPanorama) BOOL panorama;
/**
 *  是否在播放时下载,边下边播，默认为NO
 */
@property (nonatomic, assign) BOOL shouldDownloadWhilePlaying;
/**
 *  自定义缓存策略，建议开启，提升性能，默认为YES
 */
@property (nonatomic, assign) BOOL customCache;
/**
 *  是否静音，默认为NO
 */
@property (nonatomic, assign, getter=isMuted) BOOL muted;
/**
 *  是否是网络视频
 */
@property (nonatomic, assign, getter=isNetworkVideo, readonly) BOOL networkVideo;


@property (nonatomic, weak) id<FYPlayerDelegate> delegate;

- (void)setUrl:(NSURL*)url panorama:(BOOL)panorama;

- (void)play;
- (void)pause;
- (void)seekToTime:(CGFloat)time complete:(void (^)(BOOL finish))complete;

@end
