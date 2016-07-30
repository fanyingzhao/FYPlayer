//
//  FYLoadingView.m
//  FFKit
//
//  Created by fan on 16/7/27.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "FYLoadingView.h"

@interface FYLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView* indicatorView;
@end

@implementation FYLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.indicatorView.center = self.center;
}

#pragma mark - setUp
- (void)setUp {
    self.userInteractionEnabled = NO;
    [self addSubview:self.indicatorView];
}

#pragma mark - funcs
- (void)startLoadingAnimation {
    [self.indicatorView startAnimating];
}

- (void)stopLoadingAnimation {
    [self.indicatorView stopAnimating];
}

#pragma mark - getter
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicatorView;
}
@end
