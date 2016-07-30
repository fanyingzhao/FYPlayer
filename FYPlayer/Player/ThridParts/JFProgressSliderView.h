//
//  JFProgressSliderView.h
//  JFPlayer
//
//  Created by fan on 16/6/16.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JFProgressSliderView;
@protocol JFProgressSliderViewDelegate <NSObject>

- (void)progressSliderTouchBegan:(JFProgressSliderView*)progressSliderView;
- (void)progressSliderTouchEnded:(JFProgressSliderView*)progressSliderView;
- (void)progressSliderValueChanged:(JFProgressSliderView*)progressSliderView;
@end

@interface JFProgressSliderView : UIView

@property (nonatomic, strong, readonly) UISlider* progressSlider;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic,weak) id<JFProgressSliderViewDelegate> delegate;

@end
