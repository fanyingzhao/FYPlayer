//
//  FYMotionHelper.h
//  VRPlayer
//
//  Created by fanyingzhao on 16/4/4.
//  Copyright © 2016年 fyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <GLKit/GLKit.h>

@interface JFMotionHelper : NSObject

@property (nonatomic, assign, getter=isGravity) BOOL gravity;       // 当前是否使用重力感应

@property (nonatomic, strong) CMAttitude* referenceAttitude;
@property (nonatomic, strong) CMAttitude* currentAttitude;
@property (nonatomic, strong) CMMotionManager* motionManager;


+ (instancetype)shareInstance;

- (GLKMatrix4)gravityMatrix:(UIDeviceOrientation)orientation;


- (void)startDeviceMotion;
- (void)stopDeviceMotion;

@end
