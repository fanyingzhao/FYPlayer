//
//  JFCustomButton.m
//  JFPlayer
//
//  Created by fan on 16/6/17.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "JFCustomButton.h"

@interface JFCustomButton ()
{
    NSString* _normalImage;
    NSString* _pressImage;
    NSString* _selectedImage;
    NSString* _selectedPressImage;
    
    __weak id _target;
    SEL _selector;
    CGRect _originFrame;
}

@end

@implementation JFCustomButton

- (instancetype)init
{
    if (self = [super init])
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeTopLeft;
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn addTarget:self action:@selector(btnClickDown:) forControlEvents:UIControlEventTouchDown];
        [_btn addTarget:self action:@selector(btnClickUp:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_imageView];
        [self addSubview:_btn];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeTopLeft;
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn addTarget:self action:@selector(btnClickDown:) forControlEvents:UIControlEventTouchDown];
        [_btn addTarget:self action:@selector(btnClickUp:) forControlEvents:UIControlEventTouchUpInside];
        _btn.frame = frame;
        
        [self addSubview:_imageView];
        [self addSubview:_btn];
    }
    
    return self;
}

- (void)dealloc
{
//    NSLog(@"按钮 释放了");
}

#pragma mark - layout

#pragma mark - tools
- (void)setBackImage:(NSString*)imageUrl
{
    self.imageView.image = [UIImage imageNamed:imageUrl];
    [self.imageView sizeToFit];
    self.imageView.center = ({
        CGPoint point;
        point.x = CGRectGetWidth(self.bounds) / 2;
        point.y = CGRectGetHeight(self.bounds) / 2;
        point;
    });
}

- (void)setFrame:(CGRect)frame
{
    _originFrame = frame;
    
    self.imageView.center = ({
        CGPoint point;
        point.x = CGRectGetWidth(frame) / 2;
        point.y = CGRectGetHeight(frame) / 2;
        point;
    });
    
    // 更新位置
    switch (self.model) {
        case AlignModelTop:
        {
            frame = CGRectOffset(frame, 0, -[self getImageMargin:0]);
        }
            break;
        case AlignModelRight:
        {
            frame = CGRectOffset(frame, [self getImageMargin:1], 0);
        }
            break;
        case AlignModelBottom:
        {
            frame = CGRectOffset(frame, 0, [self getImageMargin:2]);
        }
            break;
        case AlignModelLeft:
        {
            frame = CGRectOffset(frame, -[self getImageMargin:3], 0);
        }
            break;
        case AlignModelTopLeft:
        {
            frame = CGRectOffset(frame, -[self getImageMargin:3], -[self getImageMargin:0]);
        }
            break;
        case AlignModelTopRight:
        {
            frame = CGRectOffset(frame, [self getImageMargin:1], -[self getImageMargin:0]);
        }
            break;
        case AlignModelBottomLeft:
        {
            frame = CGRectOffset(frame, -[self getImageMargin:3], [self getImageMargin:2]);
        }
            break;
        case AlignModelBottomRight:
        {
            frame = CGRectOffset(frame, [self getImageMargin:1], [self getImageMargin:2]);
        }
            break;
        case AlignModelNone:
        {
            
        }
            break;
        default:
            break;
    }
    
    [super setFrame:frame];
    
    self.btn.frame = self.bounds;
}

// 上，右，下，左
- (CGFloat)getImageMargin:(int)direction
{
    CGFloat marign = -1;
    
    if (direction == 0)
    {
        return CGRectGetMinY(self.imageView.frame);
    }
    else if (direction == 1)
    {
        return CGRectGetWidth(_originFrame) - CGRectGetMaxX(self.imageView.frame);
    }
    else if (direction == 2)
    {
        return CGRectGetHeight(_originFrame) - CGRectGetMaxY(self.imageView.frame);
    }
    else if (direction == 3)
    {
        return CGRectGetMinX(self.imageView.frame);
    }
    
    return marign;
}

#pragma mark - funcs
- (void)setNormalImage:(NSString*)normalImage pressedImage:(NSString*)pressImage
{
    _normalImage = normalImage;
    _pressImage = pressImage;
    
    [self setBackImage:_normalImage];
}

- (void)setNormalImage:(NSString *)normalImage pressedImage:(NSString *)pressImage
         selectedImage:(NSString *)selectedImage selectedPressImage:(NSString *)selectedPressImage
{
    _normalImage = normalImage;
    _pressImage = pressImage;
    _selectedImage = selectedImage;
    _selectedPressImage = selectedPressImage;
    
    if (self.selected)
    {
        [self setBackImage:_selectedImage];
    }
    else
    {
        [self setBackImage:_normalImage];
    }
}

- (void)addTargetBtnEvent:(id)target selector:(SEL)selector
{
    _target = target;
    _selector = selector;
}

#pragma mark - events
- (void)btnClickDown:(UIButton*)sender
{
    if (self.selected)
    {
        [self setBackImage:_selectedPressImage];
    }
    else
    {
        [self setBackImage:_pressImage];
    }
}

- (void)btnClickUp:(UIButton*)sender
{
    if (self.selected)
    {
        [self setBackImage:_selectedImage];
    }
    else
    {
        [self setBackImage:_normalImage];
    }
    
    [_target performSelectorOnMainThread:_selector withObject:self waitUntilDone:NO];
}

#pragma mark - setter;
- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected)
    {
        [self setBackImage:_selectedImage];
    }
    else
    {
        [self setBackImage:_normalImage];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    self.btn.enabled = enabled;
}

@end
