//
//  JFCustomButton.h
//  JFPlayer
//
//  Created by fan on 16/6/17.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AlignModel) {
    AlignModelLeft,
    AlignModelRight,
    AlignModelTop,
    AlignModelBottom,
    AlignModelTopLeft,
    AlignModelTopRight,
    AlignModelBottomLeft,
    AlignModelBottomRight,
    AlignModelNone,
};

@interface JFCustomButton : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) AlignModel model;

@property (nonatomic, strong) UIButton* btn;
@property (nonatomic, strong) UIImageView* imageView;


- (void)setNormalImage:(NSString*)normalImage pressedImage:(NSString*)pressImage;
- (void)setNormalImage:(NSString*)normalImage pressedImage:(NSString*)pressImage
         selectedImage:(NSString*)selectedImage selectedPressImage:(NSString*)selectedPressImage;

- (void)addTargetBtnEvent:(id)target selector:(SEL)selector;

@end
