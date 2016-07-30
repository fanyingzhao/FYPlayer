//
//  UIButton+FYAdd.m
//  FFKit
//
//  Created by fan on 16/7/27.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "UIButton+FYAdd.h"
#import "NSString+FYAdd.h"

@implementation UIButton (FYAdd)

+ (UIButton *)buttonWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target selector:(SEL)selector {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image) {
        [btn setImage:image forState:UIControlStateNormal];
    }
    if (highImage) {
        [btn setImage:highImage forState:UIControlStateHighlighted];
    }
    if (selector && target) {
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    btn.frame = ({
        CGRect rect;
        rect.size.height = 30;
        rect.size.width = image.size.width / image.size.height * CGRectGetHeight(rect);
        rect.origin.x = rect.origin.y = 0;
        rect;
    });
    return btn;
}

+ (UIButton *)buttonWithTitle:(NSString *)title normalColor:(UIColor *)normalColor highColor:(UIColor *)highColor font:(UIFont *)font target:(id)target selector:(SEL)selector {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([title isValid]) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (normalColor) {
        [btn setTitleColor:normalColor forState:UIControlStateNormal];
    }
    if (highColor) {
        [btn setTitleColor:highColor forState:UIControlStateHighlighted];
    }
    if (font) {
        btn.titleLabel.font = font;
    }
    if (selector) {
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    CGSize size = [btn sizeThatFits:CGSizeMake(MAXFLOAT, 30)];
    btn.frame = ({
        CGRect rect;
        rect.size = size;
        rect.origin.x = rect.origin.y = 0;
        rect;
    });
    return btn;
}
@end
