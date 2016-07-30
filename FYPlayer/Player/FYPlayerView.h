//
//  FYPlayerView.h
//  FYPlayer
//
//  Created by fan on 16/7/20.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYPlayer.h"
#import "FYPlayerUIView.h"

@class FYPlayerView;
@protocol FYPlayerViewDelegate <NSObject>
@optional
- (void)playerViewBackBtnDidTouched:(FYPlayerView*)playerView;
- (void)playerViewFullBtnDidTouched:(FYPlayerView*)playerView;

@end

@interface VideoModel : NSObject
@property (nonatomic, strong) NSURL* videoUrl;
@property (nonatomic, assign, getter=isPanorama) BOOL panorama;            // 是否是全景视频
@end

@interface FYPlayerView : UIView

@property (nonatomic, strong, readonly) FYPlayer* player;

@property (nonatomic, weak) id <FYPlayerViewDelegate> delegate;

@property (nonatomic, strong, readonly) FYPlayerUIView* coverView;
/**
 *  当前播放的视频项，设置这个属性会导致播放列表失效
 */
@property (nonatomic, strong) VideoModel* model;
/**
 *  播放列表的当前进度
 */
@property (nonatomic, assign) NSInteger index;
/**
 *  播放列表
 */
@property (nonatomic, strong) NSMutableArray* playList;
/**
 *  是否在播放时下载,边下边播
 */
@property (nonatomic, assign) BOOL shouldDownloadWhilePlaying;
/**
 *  自定义缓存，在大码率视频时建议开启
 */
@property (nonatomic, assign) BOOL customCache;
/**
 *  是否全屏
 */
@property (nonatomic, assign, getter=isFull) BOOL full;
/**
 *  播放模式
 */
@property (nonatomic, assign) PlayModel playModel;


- (void)play;
- (void)pause;
- (void)seekToTime:(CGFloat)time;


@end
