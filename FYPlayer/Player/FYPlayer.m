//
//  FYPlayer.m
//  FYPlayer
//
//  Created by fan on 16/7/20.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "FYPlayer.h"
#import "FYKitMacro.h"

#define ONE_FRAME_DURATION                      0.03
#define SYNCHRONIZE_PIXELBUFFER_FRAEMS          30

NSString * const kVideoPlayerErrorDomain = @"kVideoPlayerErrorDomain";

static void *VideoPlayer_PlayerItemStatusContext = &VideoPlayer_PlayerItemStatusContext;
static void *VideoPlayer_PlayerExternalPlaybackActiveContext = &VideoPlayer_PlayerExternalPlaybackActiveContext;
static void *VideoPlayer_PlayerRateChangedContext = &VideoPlayer_PlayerRateChangedContext;
static void *VideoPlayer_PlayerItemPlaybackLikelyToKeepUp = &VideoPlayer_PlayerItemPlaybackLikelyToKeepUp;
static void *VideoPlayer_PlayerItemPlaybackBufferEmpty = &VideoPlayer_PlayerItemPlaybackBufferEmpty;
static void *VideoPlayer_PlayerItemLoadedTimeRangesContext = &VideoPlayer_PlayerItemLoadedTimeRangesContext;
static void *VideoPlayer_PlayerRateContext = &VideoPlayer_PlayerRateContext;

@interface FYPlayer ()<JFUrlResouerLoaderToolDelegate> {
    NSInteger _synchronizePixel;              // 全景视频同步帧数
    BOOL _synchronizeFinish;                  // 全景视频是否同步完成
    id _timeObserverToken;
}

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* item;
@property (nonatomic, strong) AVURLAsset* asset;
@property (nonatomic, strong) AVPlayerItemVideoOutput* videoOutput;
@property (nonatomic, strong) JFUrlResouerLoaderTool* resouerLoader;

@property (nonatomic, strong) NSURL* url;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat currentTime;
@property (nonatomic, assign, getter=isNetworkVideo) BOOL networkVideo;

@end

@implementation FYPlayer

- (instancetype)init {
    if (self = [super init]) {
        _customCache = YES;
    }
    return self;
}

- (void)dealloc {
    [self reset];
    FYLog(@"player 销毁");
}

#pragma mark - initializaiton
- (AVURLAsset*)getAsset {
    AVURLAsset* asset = nil;
    NSURL* url = _url;
    if ((self.shouldDownloadWhilePlaying || self.customCache) && self.isNetworkVideo) {
        NSURLComponents* components = [NSURLComponents componentsWithURL:_url resolvingAgainstBaseURL:NO];
        components.scheme = @"streaming";
        url = [components URL];
        
        self.resouerLoader = [[JFUrlResouerLoaderTool alloc] initWithUrl:_url];
        self.resouerLoader.shouldDownloadWhilePlaying = self.shouldDownloadWhilePlaying;
        asset = [AVURLAsset assetWithURL:url];
        [asset.resourceLoader setDelegate:self.resouerLoader queue:dispatch_get_main_queue()];
    }else {
        asset = [AVURLAsset assetWithURL:url];
        self.resouerLoader = nil;
    }
    
    return asset;
}

- (AVPlayerItem*)getPlayerItem {
    AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:self.asset];
    return item;
}

#pragma mark - monitor
- (void)addPlayerItemMonitor {
    [self.item addObserver:self
                forKeyPath:NSStringFromSelector(@selector(status))
                   options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                   context:VideoPlayer_PlayerItemStatusContext];
    [self.item addObserver:self
                forKeyPath:NSStringFromSelector(@selector(playbackBufferEmpty))
                   options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                   context:VideoPlayer_PlayerItemPlaybackBufferEmpty];
    [self.item addObserver:self
                forKeyPath:NSStringFromSelector(@selector(playbackLikelyToKeepUp))
                   options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                   context:VideoPlayer_PlayerItemPlaybackLikelyToKeepUp];
    [self.item addObserver:self
                forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))
                   options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                   context:VideoPlayer_PlayerItemLoadedTimeRangesContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)removePlayerItemMonitor {
    @try {
        [self.item removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(status))
                           context:VideoPlayer_PlayerItemStatusContext];
    }@catch (NSException *exception) {
        NSLog(@"Exception removing observer: %@", exception);
    }
    
    @try {
        [self.item removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(playbackLikelyToKeepUp))
                           context:VideoPlayer_PlayerItemPlaybackLikelyToKeepUp];
    }@catch (NSException *exception) {
        NSLog(@"Exception removing observer: %@", exception);
    }
    
    @try {
        [self.item removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(playbackBufferEmpty))
                           context:VideoPlayer_PlayerItemPlaybackBufferEmpty];
    }@catch (NSException *exception) {
        NSLog(@"Exception removing observer: %@", exception);
    }
    
    @try {
        [self.item removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))
                           context:VideoPlayer_PlayerItemLoadedTimeRangesContext];
    } @catch (NSException *exception) {
        NSLog(@"Exception removing observer: %@", exception);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.item];
}

- (void)addVideoOutput {
    if (!self.videoOutput) {
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        dispatch_queue_t myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
        [_videoOutput setDelegate:nil queue:myVideoOutputQueue];
        
        [self.item addOutput:self.videoOutput];
        [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
    }
}

- (void)removeVideoOutput {
    if (self.videoOutput) {
        [self.item removeOutput:self.videoOutput];
        self.videoOutput = nil;
    }
}

#pragma mark - tools
- (void)reset {
    if (self.item) {
        [self removeVideoOutput];
        [self removePlayerItemMonitor];
        self.item = nil;
    }
    if (self.player) {
        [self removeTimeObserver];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        [self.player removeObserver:self forKeyPath:NSStringFromSelector(@selector(rate))];
        self.player = nil;
    }
    self.resouerLoader = nil;
    
    _playing = NO;
    _synchronizeFinish = NO;
}

- (void)initPlay {
    if (self.panorama) {
        // 如果是全景视频，先静音，音视频同步后恢复
        self.player.muted = YES;
        [self addVideoOutput];
    }
    [self addPlayerItemMonitor];
    [self.player replaceCurrentItemWithPlayerItem:self.item];
    [self addTimeObserver];
    
    [self.player addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(rate))
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:VideoPlayer_PlayerRateContext];
}

- (void)play {
    _playing = YES;
    [self.player play];
}

- (void)seekToTime:(CGFloat)time complete:(void (^)(BOOL))complete {
    CMTime dragedCMTime = CMTimeMake(time, 1);
    [self.player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (complete) {
            complete(finished);
        }
    }];
}

- (void)pause {
    _playing = NO;
    [self.player pause];
}

- (void)addTimeObserver {
    @weakify(self);
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.f, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self);
        [self playerPeriodicCallback:time];
    }];
}

- (void)removeTimeObserver {
    [self.player removeTimeObserver:_timeObserverToken];
    _timeObserverToken = nil;
}

- (void)checkVideoSource:(NSURL*)url {
    if ([url.scheme isEqualToString:@"http"]) {
        _networkVideo = YES;
    }else if ([url.scheme isEqualToString:@"file"]) {
        _networkVideo = NO;
    }
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == VideoPlayer_PlayerItemStatusContext) {
        AVPlayerItemStatus newStatus = (AVPlayerItemStatus)[[change objectForKey:NSKeyValueChangeNewKey] integerValue];

        switch (newStatus) {
            case AVPlayerItemStatusUnknown:
            {
                
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                [self playFailure];
            }
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                if (!self.panorama) {
                    // 全景视频时只有当音视频同步才视为准备完毕
                    [self playerReadyToPlayer];
                }
            }
                break;
                
            default:
                break;
        }
    }else if (context == VideoPlayer_PlayerRateContext) {

    }else if (context == VideoPlayer_PlayerItemPlaybackLikelyToKeepUp) {
        if (!self.player.rate && self.playing) {
            [self hiddenLoadingView];
            [self play];
        }
    }else if (context == VideoPlayer_PlayerItemPlaybackBufferEmpty) {
        if (self.player.rate && self.playing) {
            [self showLoadingView];
        }
    }else if (context == VideoPlayer_PlayerItemLoadedTimeRangesContext) {
        
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - delegate
- (void)playFailure {
    NSError* error  =[NSError errorWithDomain:kVideoPlayerErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"播放失败"}];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didFailureWithError:)]) {
        [self.delegate videoPlayer:self didFailureWithError:error];
    }
}

- (void)showLoadingView {
    if ([self.delegate respondsToSelector:@selector(videoPlayerShowLoadingView:)]) {
        [self.delegate videoPlayerShowLoadingView:self];
    }
}

- (void)hiddenLoadingView {
    if ([self.delegate respondsToSelector:@selector(videoPlayerHiddenLoadingView:)]) {
        [self.delegate videoPlayerHiddenLoadingView:self];
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification*)noti {
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidReachEnd:)]) {
        [self.delegate videoPlayerDidReachEnd:self];
    }
}

- (void)playerReadyToPlayer {
    if ([self.delegate respondsToSelector:@selector(videoPlayerReadyToPlayVideo:)]) {
        [self.delegate videoPlayerReadyToPlayVideo:self];
    }
}

- (void)playerPeriodicCallback:(CMTime)time {
    if ([self.delegate respondsToSelector:@selector(videoPlayer:periodicCallback:)]) {
        [self.delegate videoPlayer:self periodicCallback:CMTimeGetSeconds(time)];
    }
}

#pragma mark - JFUrlResouerLoaderToolDelegate
- (void)videoPlayerDownloadFailure:(NSError *)error {
    [self playFailure];
}

#pragma mark - VideoDrawModelDelegate
- (CVPixelBufferRef)getVideoBufferPixel {
    CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:self.item.currentTime itemTimeForDisplay:nil];
    if (NULL == pixelBuffer) {
        _synchronizePixel ++;
        if (_synchronizePixel > SYNCHRONIZE_PIXELBUFFER_FRAEMS) {
            [self removeVideoOutput];
            [self addVideoOutput];
            _synchronizePixel = 0;
        }
    }else {
        if (!_synchronizeFinish) {
            [self playerReadyToPlayer];
            self.player.muted = self.muted;
            _synchronizeFinish = YES;
        }
    }
    
    return pixelBuffer;
}

#pragma mark - funcs
- (void)setUrl:(NSURL *)url panorama:(BOOL)panorama {
    if (!url) {
        [self playFailure];
        [self reset];
        return;
    }
    
    [self reset];
    
    _url = url;
    [self checkVideoSource:url];
    _panorama = panorama;
    self.asset = [self getAsset];
    self.item = [self getPlayerItem];
    self.player = [[AVPlayer alloc] init];
    
    [self initPlay];
    [self play];
}

#pragma mark - setter
- (void)setMuted:(BOOL)muted {
    _muted = muted;
    self.player.muted = muted;
}

- (void)setShouldDownloadWhilePlaying:(BOOL)shouldDownloadWhilePlaying {
    _shouldDownloadWhilePlaying = shouldDownloadWhilePlaying;
}

#pragma mark - getter
- (CGFloat)duration {
    _duration = CMTimeGetSeconds(self.item.duration);
    if (isnan(_duration)) _duration = 0;
    return _duration;
}

- (CGFloat)currentTime {
    _currentTime = CMTimeGetSeconds(self.item.currentTime);
    if (isnan(_currentTime)) _currentTime = 0;
    return _currentTime;
}

@end
