//
//  FYPlayerView.m
//  FYPlayer
//
//  Created by fan on 16/7/20.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "FYPlayerView.h"
#import "GLRender.h"
#import "FYPlayerAttachView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoDownloadManager.h"

@implementation VideoModel

@end

#define FULL_ANIMATION_DURATION                 0.3

@interface FYPlayerView ()<FYPlayerDelegate> {
    CGRect _originRect;
    CGFloat _sumTime;
    BOOL _horizontalMove;               // 当前是否正在水平移动
    BOOL _isVolume;                 // 当前正在改变的是否是音量
}
@property (nonatomic, strong) FYPlayer* player;
@property (nonatomic, strong) FYPlayerUIView* coverView;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, strong) GLRender* render;
@property (nonatomic, strong) FYPlayerAttachView* attachView;

@property (nonatomic, strong) UISlider* volumeViewSlider;


@end

@implementation FYPlayerView

#pragma mark - lifecircle
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _originRect = frame;
        [self setUp];
    }
    return self;
}

- (void)dealloc {
    [self.attachView removeFromSuperview];
}

#pragma mark - init
- (void)setUp {
    _player = [[FYPlayer alloc] init];
    _player.delegate = self;
    _player.shouldDownloadWhilePlaying = YES;
    
    [self addSubview:self.coverView];
    [self addVolumeView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    [self addGestureRecognizer:panGesture];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    self.coverView.frame = self.bounds;
}

- (void)didMoveToWindow {
    _attachView = [[FYPlayerAttachView alloc] init];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows lastObject];
    }
    [window addSubview:_attachView];
}

#pragma mark - initPlayer
- (void)addPlayerLayer {
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player.player];
    _playerLayer.frame = self.bounds;
    [self.layer insertSublayer:_playerLayer below:self.coverView.layer];
}

- (void)removePlayerLayer {
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
}

- (void)addRender {
    _render = [[GLRender alloc] initWithLayer:(CAEAGLLayer*)self.layer];
    _render.delegate = _player;
    if (self.full)  self.render.playModel = PlayModelVRPanorama;
    else  self.render.playModel = PlayModelPanorama;
}

- (void)removeRender {
    [_render freeOpenGLESResources];
    [_render destoryRender];
}

#pragma mark - ui
- (void)addVolumeView
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:({
        CGRect rect;
        rect.origin.x = -100;
        rect.origin.y = -100;
        rect;
    })];
    [self addSubview:volumeView];
    
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

#pragma mark - tools
- (void)seekToTime:(CGFloat)time {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"seekToTimeNotification" object:nil];
    
    if (self.player.isNetworkVideo) {
        [self.coverView showLoadingView];
    }

    [self.coverView setProgressLabel:time duration:self.player.duration];
    [self.coverView setProgressSlider:time];
    [self.player seekToTime:time complete:^(BOOL finish) {
        [self play];
        [self.coverView hiddenLoadingView];
    }];
}

- (NSURL*)updateVideoLocalIsExists:(NSURL*)url {
    if ([[VideoDownloadManager sharedDownloadManager] checkVideoIsDownloadFinish:url]) {
        return [[VideoDownloadManager sharedDownloadManager] getLocalVideoUrl:url];
    }
    
    return url;
}

#pragma mark - funcs
- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

#pragma mark - events
- (void)onTap:(UITapGestureRecognizer*)tap {
    if (self.coverView.isBarShowing) {
        [self.coverView hiddenBarView:nil];
        self.coverView.barShowing = NO;
    }else {
        [self.coverView showBarView:nil];
        self.coverView.barShowing = YES;
    }
}

- (void)panHandle:(UIPanGestureRecognizer*)pan {
    if (self.coverView.lock) {
        return;
    }
    
    CGPoint locationPoint = [pan locationInView:self];
    CGPoint veloctyPoint = [pan velocityInView:self];
    CGFloat x = fabs(veloctyPoint.x);
    CGFloat y = fabs(veloctyPoint.y);
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (x > y) {
                // 水平移动
                _horizontalMove = YES;
                
                [self pause];
                [self.coverView cancleDelayHiddenBarView];
                [self.coverView showBarView:nil];
                
                _sumTime = self.player.currentTime;
            }else {
                // 垂直移动
                if (locationPoint.x > self.bounds.size.width / 2) {
                    _isVolume = YES;
                    self.attachView.bright = NO;
                }else {
                    _isVolume = NO;
                    self.attachView.bright = YES;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_horizontalMove) {
                _sumTime += veloctyPoint.x / 200;
                if (_sumTime > self.player.duration) _sumTime = self.player.duration;
                if (_sumTime < 0) _sumTime = 0;
                
                [self.coverView showSeekView:_sumTime];
            }else {
                if (_isVolume) {
                    self.volumeViewSlider.value -= veloctyPoint.y / 10000;
                    [self.attachView volumeChanged:self.volumeViewSlider.value];
                }else {
                    ([UIScreen mainScreen].brightness -= veloctyPoint.y / 10000);
                }
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        {
            if (_horizontalMove) {
                [self.coverView autoDelayHiddenBarView:nil];
                [self seekToTime:_sumTime];
                [self.coverView hiddenSeekView];
            }else {
                
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)pin {
    
}

#pragma mark - FYPlayerDelegate
- (void)videoPlayerReadyToPlayVideo:(FYPlayer *)player {
    [self.coverView setProgressSliderMaxValue:player.duration];
    [self.coverView autoDelayHiddenBarView:nil];
}

- (void)videoPlayer:(FYPlayer *)player periodicCallback:(CGFloat)time {
    [self.coverView setProgressLabel:time duration:player.duration];
    [self.coverView setProgressSlider:time];
}

- (void)videoPlayerDidReachEnd:(FYPlayer *)player {
    [self.coverView resetPlayProgress];
    
    // 如果是播放列表，判断是否还有需要播放的项目
    if (_index < self.playList.count - 1) {
        _index ++;
        self.model = self.playList[_index];
    }
}

- (void)videoPlayer:(FYPlayer *)player didFailureWithError:(NSError *)error {
    
}

- (void)videoPlayerShowLoadingView:(FYPlayer *)player {
    [self.coverView showLoadingView];
}

- (void)videoPlayerHiddenLoadingView:(FYPlayer *)player {
    [self.coverView hiddenLoadingView];
}

#pragma mark - setter
- (void)setModel:(VideoModel *)model {
    _model = model;
    
    [self.player setUrl:[self updateVideoLocalIsExists:model.videoUrl] panorama:model.panorama];
    if (model.panorama) {
        [self removePlayerLayer];
        [self addRender];
        if (self.playModel == PlayModelVRPanorama) self.playModel = PlayModelVRPanorama;
        else    self.playModel = PlayModelPanorama;
        self.coverView.panorama = YES;
    }else {
        [self removeRender];
        [self addPlayerLayer];
        self.playModel = PlayModelNormal;
        self.coverView.panorama = NO;
    }
}

- (void)setFull:(BOOL)full {
    _full = full;
    
    if (full) {
        [UIView animateWithDuration:FULL_ANIMATION_DURATION animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.frame = [UIScreen mainScreen].bounds;
            [self layoutIfNeeded];
            self.attachView.landspace = YES;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        }];
    }else {
        [UIView animateWithDuration:FULL_ANIMATION_DURATION animations:^{
            self.transform = CGAffineTransformIdentity;
            self.frame = _originRect;
            [self layoutIfNeeded];
            self.attachView.landspace = NO;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        }];
    }
}

- (void)setPlayModel:(PlayModel)playModel {
    self.render.playModel = playModel;
}

- (void)setPlayList:(NSMutableArray *)playList {
    NSAssert(![[_playList firstObject] isKindOfClass:[VideoModel class]], @"播放列表中元素必须为 VideoModel 类型");

    _playList = playList;
    _index = 0;
    self.model = [_playList firstObject];
}

- (void)setShouldDownloadWhilePlaying:(BOOL)shouldDownloadWhilePlaying {
    self.player.shouldDownloadWhilePlaying = shouldDownloadWhilePlaying;
}

- (void)setCustomCache:(BOOL)customCache {
    self.player.customCache = customCache;
}

#pragma mark - getter
- (BOOL)shouldDownloadWhilePlaying {
    return self.player.shouldDownloadWhilePlaying;
}

- (BOOL)customCache {
    return self.player.customCache;
}

- (PlayModel)playModel {
    return self.render.playModel;
}

- (FYPlayerUIView *)coverView {
    if (!_coverView) {
        _coverView = [[FYPlayerUIView alloc] initWithFrame:self.bounds];
        _coverView.player = self;
    }
    return _coverView;
}

@end
