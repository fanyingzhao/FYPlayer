//
//  FYPlayerUIView.h
//  FYPlayer
//
//  Created by fan on 16/7/21.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFCustomButton.h"
#import "JFProgressSliderView.h"

@class FYPlayerView;
@interface FYPlayerUIView : UIView

@property (nonatomic, weak) FYPlayerView* player;

@property (nonatomic, strong, readonly) UIView* topView;
@property (nonatomic, strong, readonly) UIView* bottomView;
@property (nonatomic, assign, getter=isLock) BOOL lock;
@property (nonatomic, assign, getter=isVr) BOOL vr;
@property (nonatomic, assign, getter=isPanorama) BOOL panorama;
@property (nonatomic, assign, getter=isBarShowing) BOOL barShowing;

// barView
- (void)showBarView:(void (^)(BOOL finish))complete;
- (void)hiddenBarView:(void (^)(BOOL finish))complete;
- (void)autoDelayHiddenBarView:(void (^)(BOOL finish))complete;
- (void)cancleDelayHiddenBarView;

// seek view
- (void)showSeekView:(CGFloat)seekTime;
- (void)hiddenSeekView;

// bottom
- (void)setProgressLabel:(CGFloat)time duration:(CGFloat)duration;
- (void)setProgressSlider:(CGFloat)progress;
- (void)setProgressSliderMaxValue:(CGFloat)maxValue;

// loadingView
- (void)showLoadingView;
- (void)hiddenLoadingView;

- (void)resetPlayProgress;


@end
