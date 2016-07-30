//
//  FYPlayerAttachView.h
//  FYPlayer
//
//  Created by fan on 16/7/21.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYPlayerAttachView : UIView

@property (nonatomic, strong) NSMutableArray* brightList;

@property (nonatomic, strong) NSMutableArray* volumeList;

@property (nonatomic, assign, getter=isBright) BOOL bright;

@property (nonatomic, assign, getter=isLandspace) BOOL landspace;

- (void)volumeChanged:(CGFloat)value;

@end
