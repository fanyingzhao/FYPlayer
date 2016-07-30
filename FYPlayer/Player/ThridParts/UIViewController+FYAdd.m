//
//  UIViewController+FYAdd.m
//  FFKit
//
//  Created by fan on 16/6/29.
//  Copyright © 2016年 fan. All rights reserved.
//

#define SYSTEM_NAVITEM_FONT     17

#import "UIViewController+FYAdd.h"
#import "UIButton+FYAdd.h"

@implementation UIViewController (FYAdd)
+ (UIViewController*)getActivityViewController {
    UIViewController* activityVC = nil;
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    NSArray* subViews = window.subviews;
    if (subViews.count) {
        id nextResponer = ((UIView*)subViews[0]).nextResponder;
        if ([nextResponer isKindOfClass:[UINavigationController class]]) {
            activityVC = ((UINavigationController*)nextResponer).visibleViewController;
        }else if ([nextResponer isKindOfClass:[UIViewController class]]) {
            activityVC = nextResponer;
        }else {
            activityVC = window.rootViewController;
        }
    }
    
    return activityVC;
}

#pragma mark - status



#pragma mark - attribute


//*************************
// UI
//*************************
- (void)setNavRightItemWithImage:(UIImage *)image selector:(SEL)selector {
    [self setNavRightItemWithImage:image highImage:image selector:selector];
}

- (void)setNavRightItemWithImage:(UIImage *)image highImage:(UIImage *)highImage selector:(SEL)selector {
    UIButton* btn = [UIButton buttonWithImage:image highImage:highImage target:self selector:selector];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)setNavRightItemWithTitle:(NSString *)title selector:(SEL)selector {
    [self setNavRightItemWithTitle:title normalColor:nil highColor:nil font:[UIFont systemFontOfSize:SYSTEM_NAVITEM_FONT] selector:selector];
}

- (void)setNavRightItemWithTitle:(NSString *)title normalColor:(UIColor *)normalColor highColor:(UIColor *)highColor selector:(SEL)selector {
    [self setNavRightItemWithTitle:title normalColor:normalColor highColor:highColor font:[UIFont systemFontOfSize:SYSTEM_NAVITEM_FONT] selector:selector];
}

- (void)setNavRightItemWithTitle:(NSString *)title normalColor:(UIColor *)normalColor highColor:(UIColor *)highColor font:(UIFont *)font selector:(SEL)selector {
    UIButton* btn = [UIButton buttonWithTitle:title normalColor:normalColor highColor:highColor font:font target:self selector:selector];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - tools



@end
