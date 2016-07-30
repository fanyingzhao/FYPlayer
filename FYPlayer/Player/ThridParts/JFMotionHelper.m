//
//  FYMotionHelper.m
//  VRPlayer
//
//  Created by fanyingzhao on 16/4/4.
//  Copyright © 2016年 fyz. All rights reserved.
//

#import "JFMotionHelper.h"

@implementation JFMotionHelper

+ (instancetype)shareInstance
{
    static JFMotionHelper *motinInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motinInstance = [[self alloc] init];
    });
    
    return motinInstance;
}

#pragma mark - tools
-(GLKMatrix4) getDeviceOrientationMatrix:(UIDeviceOrientation)orientation
{
    CMRotationMatrix a = [[[_motionManager deviceMotion] attitude] rotationMatrix];
    // arrangements of mappings of sensor axis to virtual axis (columns)
    // and combinations of 90 degree rotations (rows)
    
//    CMQuaternion quaternion = [[[_motionManager deviceMotion] attitude] quaternion];
//    return [self transform:quaternion];
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        {
            return GLKMatrix4Make(-a.m11, a.m21, a.m31, 0.0f,
                                  -a.m13, a.m23, a.m33, 0.0f,
                                  a.m12,-a.m22,-a.m32, 0.0f,
                                  0.0f , 0.0f , 0.0f , 1.0f);
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            return GLKMatrix4Make(a.m21,    a.m11,  a.m31, 0.0f,
                                  a.m23,    a.m13,  a.m33, 0.0f,
                                  -a.m22,  -a.m12,  -a.m32, 0.0f,
                                  0.0f , 0.0f , 0.0f , 1.0f);
        }
            break;

        default:
            break;
    }
    
    return GLKMatrix4Identity;
}

- (GLKMatrix4)transform:(CMQuaternion)quatern {
    
    float cos_a = quatern.w;
    float angle = acos(cos_a) * 2;
    float sin_a = sqrt(1.f - cos_a * cos_a);
    if (fabs(sin_a) < 0.0005) {
        sin_a = 1;
    }
    
    float axis_x = quatern.x / sin_a;
    float axis_y = quatern.y / sin_a;
    float axis_z = quatern.w / sin_a;
    
    GLKMatrix4 mat = GLKMatrix4Identity;
    mat = GLKMatrix4Rotate(mat, angle, axis_y, axis_x, axis_z);
    
    NSLog(@"z轴旋转角度: %f ",angle);
    
    return mat;
}

#pragma mark - funcs
- (void)startDeviceMotion
{
    self.gravity = YES;
    
    _motionManager = [[CMMotionManager alloc] init];
    _referenceAttitude = nil;
    _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    _motionManager.gyroUpdateInterval = 1.0f / 60;
    _motionManager.showsDeviceMovementDisplay = YES;
    
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    
    _referenceAttitude = _motionManager.deviceMotion.attitude; // Maybe nil actually. reset it later when we have data
}

- (void)stopDeviceMotion
{
    self.gravity = NO;
    
    [_motionManager stopDeviceMotionUpdates];
    _motionManager = nil;
}

#pragma mark - getter
- (GLKMatrix4)gravityMatrix:(UIDeviceOrientation)orientation
{
    // 如果没有开启重力感应或者重力感应不可用，返回标准矩阵
    if (!self.isGravity || !self.motionManager.accelerometerAvailable) {
        return GLKMatrix4Identity;
    }
    
    
    return [self getDeviceOrientationMatrix:orientation];
}


- (CMAttitude *)currentAttitude
{
    return [[_motionManager deviceMotion] attitude];
}

@end
