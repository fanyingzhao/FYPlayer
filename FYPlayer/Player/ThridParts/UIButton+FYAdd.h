//
//  UIButton+FYAdd.h
//  FFKit
//
//  Created by fan on 16/7/27.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (FYAdd)

+ (UIButton*)buttonWithImage:(UIImage*)image
                   highImage:(UIImage*)highImage
                      target:(id)target
                    selector:(SEL)selector;

+ (UIButton*)buttonWithTitle:(NSString*)title
                 normalColor:(UIColor*)normalColor
                   highColor:(UIColor*)highColor
                        font:(UIFont*)font
                      target:(id)target
                    selector:(SEL)selector;

@end
