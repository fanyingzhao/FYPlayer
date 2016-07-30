//
//  JFProgressSliderView.m
//  JFPlayer
//
//  Created by fan on 16/6/16.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "JFProgressSliderView.h"
//#import "JFMacro.h"

@interface JFProgressSliderView ()

@property (nonatomic, strong) UISlider* progressSlider;
@end

@implementation JFProgressSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.progressSlider];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.progressSlider.frame = self.bounds;
}

#pragma mark - events
- (void)progressSliderTouchBegan:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSliderTouchBegan:)])
    {
        [self.delegate progressSliderTouchBegan:self];
    }
}

- (void)progressSliderTouchEnded:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSliderTouchEnded:)])
    {
        [self.delegate progressSliderTouchEnded:self];
    }
}

- (void)progressSliderValueChanged:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSliderValueChanged:)])
    {
        [self.delegate progressSliderValueChanged:self];
    }
}

#pragma mark - setter
- (void)setProgress:(CGFloat)progress
{
    self.progressSlider.value = progress;
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
    self.progressSlider.minimumValue = minimumValue;
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
    self.progressSlider.maximumValue = maximumValue;
}

#pragma mark - getter
- (UISlider *)progressSlider
{
    if (!_progressSlider)
    {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"btn_slide_shoot_normal"] forState:UIControlStateNormal];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"btn_slide_shoot_pressed"] forState:UIControlStateHighlighted];
        [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:254/255.f green:204/255.f blue:0/255.f alpha:1]];
        [_progressSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchCancel];
    }
    
    return _progressSlider;
}

- (CGFloat)progress
{
    return _progressSlider.value;
}

@end
