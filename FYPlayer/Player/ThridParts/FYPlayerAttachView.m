//
//  FYPlayerAttachView.m
//  FYPlayer
//
//  Created by fan on 16/7/21.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "FYPlayerAttachView.h"
#import "FYKitMacro.h"
#import <AVFoundation/AVFoundation.h>

static void *PlayerView_Brightness = &PlayerView_Brightness;

#define BRIGHTNESS      @"亮度"
#define VOLUME          @"音量"
#define SHOW_DURATION   3
#define DISMISS_ANIMATION_DURATION  0.8
#define ROTATION_ANIMATION_DURATION 0.25
#define TIP_COUNT       16

@interface FYPlayerAttachView ()

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* backImage;
@property (nonatomic, strong) UIView* longView;
@property (nonatomic, strong) NSMutableArray* tipList;
@end

@implementation FYPlayerAttachView

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect rect = ({
        CGRect rect;
        rect.size.width = 155;
        rect.size.height = 155;
        rect.origin.x = (UIDEVICE_SCREEN_WIDTH - CGRectGetWidth(rect)) / 2;
        rect.origin.y = (UIDEVICE_SCREEN_HEIGHT - CGRectGetHeight(rect)) / 2;
        rect;
    });
    if (self = [super initWithFrame:rect]) {
        [self setUp];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init
- (void)setUp {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolbar.alpha = 0.97;
    [self addSubview:toolbar];
    self.layer.cornerRadius  = 10;
    self.layer.masksToBounds = YES;
    
    self.alpha = 0;
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.backImage];
    [self addSubview:self.longView];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self createTips];
    [self addObserver];
}

- (void)createTips {
    CGFloat tipW = (self.longView.bounds.size.width - (TIP_COUNT + 1)) / TIP_COUNT;
    CGFloat tipY = 1;
    CGFloat tipH = CGRectGetHeight(self.longView.bounds) - tipY * 2;
    for (NSInteger i = 0; i < TIP_COUNT; i ++) {
        CGFloat tipX          = i * (tipW + 1) + 1;
        UIImageView *image    = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.longView addSubview:image];
        [self.tipList addObject:image];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backImage.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

- (void)addObserver {
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:PlayerView_Brightness];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChangedNotification:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateDirection:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
}

#pragma mark - funcs
- (void)volumeChangedNotification:(NSNotification*)noti {
    CGFloat value = [[noti.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    [self volumeChanged:value];
}

- (void)updateDirection:(NSNotification*)noti {
    [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
            self.center = CGPointMake(UIDEVICE_SCREEN_WIDTH / 2, (UIDEVICE_SCREEN_HEIGHT - 10) / 2);
        }else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
            self.center = CGPointMake(UIDEVICE_SCREEN_WIDTH / 2, UIDEVICE_SCREEN_HEIGHT / 2);
        }
    } completion:nil];
}

- (void)volumeChanged:(CGFloat)value {
    [self showView];
    self.titleLabel.text = VOLUME;
    
    self.backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZFPlayer_brightness@2x" ofType:@"png"]];
    if (self.volumeList) {
        NSInteger level = (value * TIP_COUNT - 1) / (TIP_COUNT / self.volumeList.count);
        if (level == 0) self.backImage.image = self.volumeList[0];
        else self.backImage.image = self.volumeList[level];
    }
    
    CGFloat stage = 1 / ((CGFloat)self.tipList.count);
    NSInteger level = value / stage;
    for (int i = 0; i < self.tipList.count; i++) {
        UIImageView *img = self.tipList[i];
        if (i < level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

- (void)brightChanged:(CGFloat)value {
    [self showView];
    self.titleLabel.text = BRIGHTNESS;
    
    self.backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZFPlayer_brightness@2x" ofType:@"png"]];
    if (self.brightList) {
        NSInteger level = (value * TIP_COUNT - 1) / (TIP_COUNT / self.brightList.count);
        if (level == 0) self.backImage.image = self.brightList[0];
        else self.backImage.image = self.brightList[level];
    }
    
    CGFloat stage = 1 / ((CGFloat)self.tipList.count);
    NSInteger level = value / stage;
    for (int i = 0; i < self.tipList.count; i++) {
        UIImageView *img = self.tipList[i];
        if (i < level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

#pragma mark - tools
- (void)showView {
    self.alpha = 1;
    [self autoDelayHidden];
}

- (void)cancleDelayHidden {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView) object:nil];
}

- (void)autoDelayHidden {
    [self cancleDelayHidden];
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:SHOW_DURATION];
}

- (void)hiddenView {
    [UIView animateWithDuration:DISMISS_ANIMATION_DURATION animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == PlayerView_Brightness) {
        CGFloat sound = [change[NSKeyValueChangeNewKey] floatValue];
        [self brightChanged:sound];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - setter
- (void)setLandspace:(BOOL)landspace {
    _landspace = landspace;
    
    [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
        if (landspace) {
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
        }else {
            self.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - getter
- (UIImageView *)backImage {
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithFrame:({
            CGRect rect;
            rect.origin.x = rect.origin.y = 0;
            rect.size.width = 79;
            rect.size.height = 76;
            rect;
        })];
        _backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZFPlayer_brightness@2x" ofType:@"png"]];
    }
    return _backImage;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:({
            CGRect rect;
            rect.origin.x = 0;
            rect.origin.y = 5;
            rect.size.width = CGRectGetWidth(self.bounds);
            rect.size.height = 30;
            rect;
        })];
        _titleLabel.font          = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text          = BRIGHTNESS;
    }
    return _titleLabel;
}

- (UIView *)longView {
    if (!_longView) {
        _longView = [[UIView alloc] initWithFrame:({
            CGRect rect;
            rect.origin.x = 13;
            rect.origin.y = 132;
            rect.size.width = CGRectGetWidth(self.bounds) - CGRectGetMinX(rect) * 2;
            rect.size.height = 7;
            rect;
        })];
        _longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
    }
    return _longView;
}

- (NSMutableArray *)tipList {
    if (!_tipList) {
        _tipList = [NSMutableArray array];
    }
    return _tipList;
}
@end
