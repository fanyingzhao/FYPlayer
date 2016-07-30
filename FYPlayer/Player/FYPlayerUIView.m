//
//  FYPlayerUIView.m
//  FYPlayer
//
//  Created by fan on 16/7/21.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "FYPlayerUIView.h"
#import "FYPlayerView.h"
#import "FYLoadingView.h"

#define BARVIEW_ANIMATION_DURATION          0.3
#define BARVIEW_LAST_DURATION               5

@interface FYPlayerUIView ()<JFProgressSliderViewDelegate>

@property (nonatomic, strong) UIView* topView;
@property (nonatomic, strong) JFCustomButton* backBtn;
@property (nonatomic, strong) JFCustomButton* downloadBtn;

@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, strong) JFCustomButton* playBtn;
@property (nonatomic, strong) UILabel* progressTimeLabel;
@property (nonatomic, strong) JFProgressSliderView* progressSliderView;
@property (nonatomic, strong) JFCustomButton* fullBtn;
@property (nonatomic, strong) FYLoadingView* loadingView;

@property (nonatomic, strong) JFCustomButton* lockBtn;
@property (nonatomic, strong) JFCustomButton* vrBtn;

@property (nonatomic, strong) UILabel *horizontalLabel;                 // 快进快退

@end

@implementation FYPlayerUIView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

#pragma mark - init
- (void)setUp {
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
    [self addSubview:self.lockBtn];
    [self addSubview:self.vrBtn];
    [self addSubview:self.horizontalLabel];
    [self addSubview:self.loadingView];
    
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    self.topView.frame = ({
        CGRect rect;
        rect.size.width = CGRectGetWidth(self.bounds);
        rect.size.height = 50;
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect;
    });
    self.backBtn.frame = ({
        CGRect rect;
        rect.size = self.backBtn.bounds.size;
        rect.origin.x = 20;
        rect.origin.y = (CGRectGetHeight(self.topView.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    self.downloadBtn.frame = ({
        CGRect rect;
        rect.size = self.downloadBtn.bounds.size;
        rect.origin.x = CGRectGetWidth(self.topView.bounds) - CGRectGetWidth(rect) - 20;
        rect.origin.y = (CGRectGetHeight(self.topView.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    
    self.bottomView.frame = ({
        CGRect rect;
        rect.size.width = CGRectGetWidth(self.bounds);
        rect.size.height = 50;
        rect.origin.x = 0;
        rect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(rect);
        rect;
    });
    self.playBtn.frame = ({
        CGRect rect;
        rect.size = self.playBtn.bounds.size;
        rect.origin.x = 20;
        rect.origin.y = (CGRectGetHeight(self.bottomView.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    self.progressTimeLabel.frame = ({
        CGRect rect;
        rect.size = self.progressTimeLabel.bounds.size;
        rect.origin.x = CGRectGetMaxX(self.playBtn.frame) + 20;
        rect.origin.y = (CGRectGetHeight(self.bottomView.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    self.fullBtn.frame = ({
        CGRect rect;
        rect.size = self.fullBtn.bounds.size;
        rect.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(rect) - 20;
        rect.origin.y = (CGRectGetHeight(self.bottomView.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    self.progressSliderView.frame = ({
        CGRect rect;
        rect.size.width = CGRectGetMinX(self.fullBtn.frame) - CGRectGetMaxX(self.progressTimeLabel.frame) - 20;
        rect.size.height = 30;
        rect.origin.x = CGRectGetMaxX(self.progressTimeLabel.frame) + 10;
        rect.origin.y = (CGRectGetHeight(self.bottomView.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    
    _horizontalLabel.frame = ({
        CGRect rect;
        rect.size.width = 150;
        rect.size.height = 33;
        rect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(rect)) / 2;
        rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    self.lockBtn.frame = ({
        CGRect rect;
        rect.size = self.lockBtn.bounds.size;
        rect.origin.x = CGRectGetMinX(self.backBtn.frame);
        rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    self.vrBtn.frame = ({
        CGRect rect;
        rect.size = self.vrBtn.bounds.size;
        rect.origin.x = CGRectGetMinX(self.downloadBtn.frame);
        rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) / 2;
        rect;
    });
    self.loadingView.frame = self.bounds;
}

#pragma mark - tools
- (NSString*)getPlayTime:(CGFloat)currentTime
{
    if (currentTime < 0.000001) {
        return @"00:00";
    }
    
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    return [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
}

- (void)cancleDelayHiddenBarView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoDelayHiddenBarView:(void (^)(BOOL finish))complete {
    [self cancleDelayHiddenBarView];
    [self performSelector:@selector(hiddenBarView:) withObject:complete afterDelay:BARVIEW_LAST_DURATION];
}

#pragma mark - events
- (void)backBtnClick:(JFCustomButton*)sender {
    if ([self.player.delegate respondsToSelector:@selector(playerViewBackBtnDidTouched:)]) {
        [self.player.delegate playerViewBackBtnDidTouched:self.player];
    }
}

- (void)fullBtnClick:(JFCustomButton*)sender {
    self.player.full = sender.selected = !sender.selected;
    
    if ([self.player.delegate respondsToSelector:@selector(playerViewFullBtnDidTouched:)]) {
        [self.player.delegate playerViewFullBtnDidTouched:self.player];
    }
}

- (void)playBtnClick:(JFCustomButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player pause];
    }else {
        [self.player play];
    }
}

- (void)lockBtnClick:(JFCustomButton*)sender {
    self.lock = sender.selected = !sender.selected;
    [self autoDelayHiddenBarView:^(BOOL finish) {
        
    }];
    
    if (self.lock) {
        self.topView.hidden = YES;
        self.bottomView.hidden = YES;
        self.vrBtn.hidden = YES;
    }else {
        self.topView.hidden = NO;
        self.bottomView.hidden = NO;
        self.vrBtn.hidden = NO;
    }
}

- (void)vrBtnClick:(JFCustomButton*)sender {
    self.vr = sender.selected = !sender.selected;
    
    if (self.player.playModel == PlayModelPanorama) {
        self.player.playModel = PlayModelVRPanorama;
    }else if (self.player.playModel == PlayModelVRPanorama) {
        self.player.playModel = PlayModelPanorama;
    }
}

#pragma mark - JFProgressSliderViewDelegate
- (void)progressSliderTouchBegan:(JFProgressSliderView *)progressSliderView {
    [self.player pause];
}

- (void)progressSliderValueChanged:(JFProgressSliderView *)progressSliderView {
    [self showSeekView:progressSliderView.progress];
}

- (void)progressSliderTouchEnded:(JFProgressSliderView *)progressSliderView {
    [self hiddenSeekView];
    [self.player seekToTime:progressSliderView.progress];
}

#pragma mark - funcs
- (void)setProgressLabel:(CGFloat)time duration:(CGFloat)duration {
    self.progressTimeLabel.text = [NSString stringWithFormat:@"%@/%@",[self getPlayTime:time],[self getPlayTime:duration]];
}

- (void)setProgressSlider:(CGFloat)progress {
    self.progressSliderView.progress = progress;
}

- (void)setProgressSliderMaxValue:(CGFloat)maxValue {
    self.progressSliderView.maximumValue = maxValue;
}

- (void)showBarView:(void (^)(BOOL))complete {
    if (self.isLock) {
        [UIView animateWithDuration:BARVIEW_ANIMATION_DURATION animations:^{
            self.lockBtn.alpha = 1.f;
        } completion:^(BOOL finished) {
            self.barShowing = YES;
            [self autoDelayHiddenBarView:nil];
            if (complete) {
                complete(finished);
            }
        }];

    }else {
        [UIView animateWithDuration:BARVIEW_ANIMATION_DURATION animations:^{
            self.topView.frame = ({
                CGRect rect;
                rect.size = self.topView.bounds.size;
                rect.origin.x = CGRectGetMinX(self.topView.frame);
                rect.origin.y = 0;
                rect;
            });
            self.bottomView.frame = ({
                CGRect rect;
                rect.size = self.bottomView.bounds.size;
                rect.origin.x = CGRectGetMinX(self.bottomView.frame);
                rect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(rect);
                rect;
            });
            self.lockBtn.alpha = 1.f;
            self.vrBtn.alpha = 1.f;
        } completion:^(BOOL finished) {
            self.barShowing = YES;
            [self autoDelayHiddenBarView:nil];
            if (complete) {
                complete(finished);
            }
        }];

    }
}

- (void)hiddenBarView:(void (^)(BOOL))complete {
    if (self.isLock) {
        self.lockBtn.alpha = 0.f;
        self.barShowing = NO;
    }else {
        [UIView animateWithDuration:BARVIEW_ANIMATION_DURATION animations:^{
            self.topView.frame = ({
                CGRect rect;
                rect.size = self.topView.bounds.size;
                rect.origin.x = CGRectGetMinX(self.topView.frame);
                rect.origin.y = -CGRectGetHeight(rect);
                rect;
            });
            self.bottomView.frame = ({
                CGRect rect;
                rect.size = self.bottomView.bounds.size;
                rect.origin.x = CGRectGetMinX(self.bottomView.frame);
                rect.origin.y = CGRectGetHeight(self.bounds);
                rect;
            });
            self.lockBtn.alpha = 0.f;
            self.vrBtn.alpha = 0.f;
        } completion:^(BOOL finished) {
            self.barShowing = NO;
            if (complete) {
                complete(finished);
            }
        }];
    }
}

- (void)showSeekView:(CGFloat)seekTime {
    self.horizontalLabel.hidden = NO;
    self.horizontalLabel.text = [self getPlayTime:seekTime];
}

- (void)hiddenSeekView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.horizontalLabel.hidden = YES;
    });
}

- (void)showLoadingView {
    [self.loadingView startLoadingAnimation];
}

- (void)hiddenLoadingView {
    [self.loadingView stopLoadingAnimation];
}

- (void)resetPlayProgress {
    [self setProgressLabel:0 duration:0];
    [self setProgressSlider:0];
}

#pragma mark - setter
- (void)setPanorama:(BOOL)panorama {
    _panorama = panorama;
    
    if (panorama) [self addSubview:self.vrBtn];
    else [self.vrBtn removeFromSuperview];
}

#pragma mark - getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_topView addSubview:self.backBtn];
        [_topView addSubview:self.downloadBtn];
    }
    return _topView;
}

- (JFCustomButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[JFCustomButton alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = 40;
            rect.size.height = 40;
            rect.origin.x = rect.origin.y = 0;
            rect;
        })];
        [_backBtn setNormalImage:@"ZFPlayer_back_full" pressedImage:@"ZFPlayer_back_full"];
        [_backBtn addTargetBtnEvent:self selector:@selector(backBtnClick:)];
    }
    return _backBtn;
}

- (JFCustomButton *)downloadBtn {
    if (!_downloadBtn) {
        _downloadBtn = [[JFCustomButton alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = 40;
            rect.size.height = 40;
            rect.origin.x = rect.origin.y = 0;
            rect;
        })];
        _downloadBtn.model = AlignModelRight;
        [_downloadBtn setNormalImage:@"ZFPlayer_download" pressedImage:@"ZFPlayer_download"];
    }
    return _downloadBtn;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = CGRectGetWidth(self.bounds);
            rect.size.height = 50;
            rect.origin.x = rect.origin.y = 0;
            rect;
        })];
        
        [_bottomView addSubview:self.playBtn];
        [_bottomView addSubview:self.progressTimeLabel];
        [_bottomView addSubview:self.progressSliderView];
        [_bottomView addSubview:self.fullBtn];
    }
    return _bottomView;
}

- (JFCustomButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[JFCustomButton alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = rect.size.height = 40;
            rect.origin.x = rect.origin.y = 0;
            rect;
        })];
        [_playBtn setNormalImage:@"ZFPlayer_pause" pressedImage:@"ZFPlayer_pause" selectedImage:@"ZFPlayer_play" selectedPressImage:@"ZFPlayer_play"];
        [_playBtn addTargetBtnEvent:self selector:@selector(playBtnClick:)];
    }
    return _playBtn;
}

- (UILabel *)progressTimeLabel {
    if (!_progressTimeLabel) {
        _progressTimeLabel = [[UILabel alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = 100;
            rect.size.height = 20;
            rect;
        })];
        _progressTimeLabel.textColor = [UIColor whiteColor];
        _progressTimeLabel.font = [UIFont systemFontOfSize:14];
        _progressTimeLabel.text = @"00:00/00:00";
    }
    return _progressTimeLabel;
}

- (JFProgressSliderView *)progressSliderView {
    if (!_progressSliderView) {
        _progressSliderView = [[JFProgressSliderView alloc] initWithFrame:CGRectZero];
        _progressSliderView.delegate = self;
    }
    return _progressSliderView;
}

- (JFCustomButton *)fullBtn {
    if (!_fullBtn) {
        _fullBtn = [[JFCustomButton alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = 40;
            rect.size.height = 40;
            rect;
        })];
        _fullBtn.model = AlignModelRight;
        [_fullBtn setNormalImage:@"ZFPlayer_fullscreen" pressedImage:@"ZFPlayer_fullscreen"
                   selectedImage:@"ZFPlayer_shrinkscreen" selectedPressImage:@"ZFPlayer_shrinkscreen"];
        [_fullBtn addTargetBtnEvent:self selector:@selector(fullBtnClick:)];
    }
    return _fullBtn;
}

- (UILabel *)horizontalLabel {
    if (!_horizontalLabel) {
        _horizontalLabel = [[UILabel alloc] init];
        _horizontalLabel.hidden = YES;
        _horizontalLabel.textColor       = [UIColor whiteColor];
        _horizontalLabel.textAlignment   = NSTextAlignmentCenter;
        _horizontalLabel.font            = [UIFont systemFontOfSize:15.0];
    }
    return _horizontalLabel;
}

- (FYLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[FYLoadingView alloc] initWithFrame:self.bounds];
    }
    return _loadingView;
}

- (JFCustomButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [[JFCustomButton alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = 40;
            rect.size.height = 40;
            rect.origin.x = 0;
            rect.origin.y = 0;
            rect;
        })];
        _lockBtn.model = AlignModelRight;
        [_lockBtn setNormalImage:@"btn_lock2_normal" pressedImage:@"btn_lock2_pressed" selectedImage:@"btn_lock1_normal" selectedPressImage:@"btn_lock1_pressed"];
        [_lockBtn addTargetBtnEvent:self selector:@selector(lockBtnClick:)];
    }
    return _lockBtn;
}

- (JFCustomButton *)vrBtn {
    if (!_vrBtn) {
        _vrBtn = [[JFCustomButton alloc] initWithFrame:({
            CGRect rect;
            rect.size.width = 40;
            rect.size.height = 40;
            rect.origin.x = 0;
            rect.origin.y = 0;
            rect;
        })];
        _vrBtn.model = AlignModelRight;
        [_vrBtn setNormalImage:@"btn_vr_normal" pressedImage:@"btn_vr_pressed" selectedImage:@"btn_retum_vr_normal" selectedPressImage:@"btn_retum_vr_pressed"];
        [_vrBtn addTargetBtnEvent:self selector:@selector(vrBtnClick:)];
    }
    return _vrBtn;
}
@end
