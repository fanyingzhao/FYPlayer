//
//  UIViewController+FYAdd.h
//  FFKit
//
//  Created by fan on 16/6/29.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FYAdd)

+ (UIViewController*)getActivityViewController;

//*************************
// UI
//*************************
- (void)setNavRightItemWithImage:(UIImage*)image selector:(SEL)selector;
- (void)setNavRightItemWithImage:(UIImage*)image highImage:(UIImage*)highImage selector:(SEL)selector;

- (void)setNavRightItemWithTitle:(NSString*)title
                        selector:(SEL)selector;
- (void)setNavRightItemWithTitle:(NSString*)title
                     normalColor:(UIColor*)normalColor
                       highColor:(UIColor*)highColor
                        selector:(SEL)selector;
- (void)setNavRightItemWithTitle:(NSString*)title
                     normalColor:(UIColor*)normalColor
                       highColor:(UIColor*)highColor
                            font:(UIFont*)font
                        selector:(SEL)selector;

@end
