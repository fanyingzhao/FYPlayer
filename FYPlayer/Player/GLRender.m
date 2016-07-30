//
//  GLRender.m
//  JFPlayer
//
//  Created by fan on 16/6/2.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "GLRender.h"
#import "JFMotionHelper.h"

#define MAX_OVERTURE 95.0
#define MIN_OVERTURE 25.0

@interface GLRender ()
{
    VideoDrawModel* videoModel;
    ImageDrawModel* imageModel;
    
    CGFloat _fingerX;
    CGFloat _fingerY;
    
    BOOL _drag;
}
@end

@implementation GLRender
@synthesize context;

- (instancetype)initWithLayer:(CAEAGLLayer *)layer
{
    if (self = [super init])
    {
        _layer = layer;
        
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:self.context];
        
        _overture = 85;
        
        preferredFramesPerSecond = 30;
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        displayLink.frameInterval = MAX(1, (60 / preferredFramesPerSecond));
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        videoModel = [[VideoDrawModel alloc] initWithContext:self.context];
        videoModel.render = self;
        
        [[JFMotionHelper shareInstance] startDeviceMotion];
        
        [self addNotificationObserver];
    }
    
    return self;
}

- (void)initImageModel:(NSString *)imageUrl
{
    imageModel = [[ImageDrawModel alloc] initWithFileName:imageUrl context:self.context];
}

- (void)initWithImage:(UIImage *)image
{
    imageModel = [[ImageDrawModel alloc] initWithImage:image context:self.context];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"render 销毁");
}

#pragma mark - notification
- (void)addNotificationObserver
{
    // 进入后台，和进入前台通知(变为活跃?)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillDismiss:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillAppear:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillDismiss:(NSNotification*)noti
{
    [self freeOpenGLESResources];
    [displayLink setPaused:YES];
}

- (void)applicationWillAppear:(NSNotification*)noti
{
    [displayLink setPaused:NO];
}

#pragma mark - update
- (void)drawView:(CADisplayLink*)displaylink
{
    [EAGLContext setCurrentContext:self.context];
    
    if (!defaultFrameBuffer)
    {
        [self initFrameBuffer];
        [self layoutSubviews];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
    
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self renderVideo];
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - render
- (void)renderVideo
{
    GLKMatrix4 projectMatrix = GLKMatrix4Identity;
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    
    switch (self.playModel) {
        case PlayModelNormal:
        {
            glViewport(0, 0, (GLint)self.drawableWidth, (GLint)self.drawableHeight);
            
            videoModel.modelViewProjectionMatrix = GLKMatrix4Multiply(projectMatrix, modelMatrix);
            [videoModel drawVideo];
        }
            break;
        case PlayModelPanorama:
        {
            glViewport(0, 0, (GLint)self.drawableWidth, (GLint)self.drawableHeight);
            
            projectMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.overture), _layer.bounds.size.width / _layer.bounds.size.height, 0.1, 1000);
            projectMatrix = GLKMatrix4RotateX(projectMatrix, M_PI);
            
            // 全屏更改矩阵
            if (self.isFullscreenMode)
            {
                modelMatrix = [[JFMotionHelper shareInstance] gravityMatrix:UIDeviceOrientationLandscapeLeft];
            }
            else
            {
                modelMatrix = [[JFMotionHelper shareInstance] gravityMatrix:UIDeviceOrientationPortrait];
            }
            
            videoModel.modelViewProjectionMatrix = [self getDeviceMatrix:modelMatrix projectMatrix:projectMatrix];
            [videoModel drawVideo];
        }
            break;
        case PlayModelVRPanorama:
        {
            projectMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.overture), (_layer.bounds.size.width / 2) / _layer.bounds.size.height, 0.1, 1000);
            projectMatrix = GLKMatrix4RotateX(projectMatrix, M_PI);
            modelMatrix = [[JFMotionHelper shareInstance] gravityMatrix:UIDeviceOrientationLandscapeLeft];
            
            glViewport(0, 0, (GLint)self.drawableWidth / 2 , (GLint)self.drawableHeight);
            videoModel.modelViewProjectionMatrix = [self getDeviceMatrix:modelMatrix projectMatrix:projectMatrix];
            // 缩放
            videoModel.modelViewProjectionMatrix = GLKMatrix4Scale(videoModel.modelViewProjectionMatrix, self.scale, self.scale, self.scale);
            videoModel.modelViewProjectionMatrix = GLKMatrix4Translate(videoModel.modelViewProjectionMatrix, -0.03, 0, 0);
            [videoModel drawVideo];
            
            glViewport((GLint)self.drawableWidth / 2 , 0, (GLint)self.drawableWidth / 2 , (GLint)self.drawableHeight);
            videoModel.modelViewProjectionMatrix = GLKMatrix4Translate(videoModel.modelViewProjectionMatrix, 0.03, 0, 0);
            [videoModel drawVideo];
        }
            break;
        case PlayModelImage:
        {
            glViewport(0, 0, (GLint)self.drawableWidth, (GLint)self.drawableHeight);

            projectMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.overture), _layer.bounds.size.width / _layer.bounds.size.height, 0.1, 1000);
            
            // 全屏更改矩阵
            if (self.isFullscreenMode)
            {
                modelMatrix = [[JFMotionHelper shareInstance] gravityMatrix:UIDeviceOrientationLandscapeLeft];
            }
            else
            {
                modelMatrix = [[JFMotionHelper shareInstance] gravityMatrix:UIDeviceOrientationPortrait];
            }
            
            imageModel.modelViewProjectionMatrix = [self getDeviceMatrix:modelMatrix projectMatrix:projectMatrix];
            [imageModel drawImage];
        }
            break;
        default:
            break;
    }
}

#pragma mark - tools
- (GLKMatrix4)getDeviceMatrix:(GLKMatrix4)modelMatrix projectMatrix:(GLKMatrix4)projectMatrix {
    
    GLint viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    GLKVector3 objVector = GLKVector3Make(1, 0, 0);
    GLKVector3 resVector = GLKMatrix4MultiplyVector3(modelMatrix, objVector);
    CGFloat screenX = resVector.x/[UIScreen mainScreen].scale;
    CGFloat scrrenY = (viewport[3] - resVector.y)/[UIScreen mainScreen].scale;
    
    GLKVector3 temp_objVector = GLKVector3Make(-1, 0, 0);
    GLKVector3 temp_resVector = GLKMatrix4MultiplyVector3(modelMatrix, temp_objVector);
    CGFloat temp_screenX = temp_resVector.x/[UIScreen mainScreen].scale;
    CGFloat temp_scrrenY = (viewport[3] - temp_resVector.y)/[UIScreen mainScreen].scale;
    
    CGFloat angle = atan((scrrenY - temp_scrrenY) / (screenX - temp_screenX));
//    NSLog(@"sin -- %f   cos -- %f",_fingerY * sin(angle),_fingerX * cos(angle));
    
    projectMatrix = GLKMatrix4RotateX(projectMatrix, -_fingerY);
    projectMatrix = GLKMatrix4RotateY(projectMatrix, -_fingerX);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(projectMatrix, modelMatrix);
    return modelViewProjectionMatrix;
}

#pragma mark - funcs
- (void)startRender
{
    [displayLink setPaused:NO];
}

- (void)endRender
{
    [displayLink setPaused:YES];
    [self finishOpenGLESCommands];
}

- (void)fingerStart {
    _drag = YES;
}

- (void)fingerRotationX:(CGFloat)fingerX fingerY:(CGFloat)fingerY {
    fingerX *= -0.005;
    fingerY *= -0.005;
    _fingerX += fingerX * self.overture / 100;
    _fingerY -= fingerY * self.overture / 100;
}

- (void)fingerEnd {
    _drag = NO;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:self.context];
    
    // 将颜色缓存与帧缓存与Core Animation 关联起来
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
    if (0 != depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
        depthRenderBuffer = 0;
    }
    
    GLint currentDrawableWidth = (GLint)self.drawableWidth;
    GLint currentDrawableHeight = (GLint)self.drawableHeight;
    
    if (0 < currentDrawableWidth &&
        0 < currentDrawableHeight) {
        
        glGenRenderbuffers(1, &depthRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, currentDrawableWidth, currentDrawableHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
    }
    
    GLenum status = glCheckFramebufferStatus(
                                             GL_FRAMEBUFFER) ;
    
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete frame buffer object %x", status);
    }
    
    // Make the Color Render Buffer the current buffer for display
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
}

- (void)deleteFrameBuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFrameBuffer) {
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        
        if (colorRenderBuffer) {
            glDeleteRenderbuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
        
        if (depthRenderBuffer) {
            glDeleteRenderbuffers(1, &depthRenderBuffer);
            depthRenderBuffer = 0;
        }
    }
}

#pragma mark - setter
- (void)setContext:(EAGLContext *)aContext
{
    if (context != aContext) {
        
        if (nil != aContext) {
            
            context = aContext;
            
            [self initFrameBuffer];
            
            [self layoutSubviews];
            
        }else {
            
            NSLog(@"context 为nil");
        }
    }
}

- (void)initFrameBuffer
{
    [EAGLContext setCurrentContext:context];
    
    if (0 != defaultFrameBuffer) {
        
        glDeleteFramebuffers(1, &defaultFrameBuffer);
        defaultFrameBuffer = 0;
    }
    
    if (0 != colorRenderBuffer) {
        
        glDeleteRenderbuffers(1, &colorRenderBuffer);
        colorRenderBuffer = 0;
    }
    
    if (0 != depthRenderBuffer) {
        
        glDeleteRenderbuffers(1, &depthRenderBuffer);
        depthRenderBuffer = 0;
    }
    
    // 创建并绑定，帧缓存，颜色缓存，深度缓存
    glGenFramebuffers(1, &defaultFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
    
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object: %i", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

#pragma mark - funcs
- (void)finishOpenGLESCommands
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        glFinish();
    }
}

- (void)freeOpenGLESResources
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        [self deleteFrameBuffer];
        glFinish();
    }
}

- (UIImage *)snapVideoImage
{
    NSInteger x = 0, y = 0;
    NSInteger width = [self drawableWidth];
    NSInteger height = [self drawableHeight];
    
    NSInteger dataLength = width * height * 4;
    
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    
    // Create a CGImage with the pixel data
    
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    
    // otherwise, use kCGImageAlphaPremultipliedLast
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    
    // OpenGL ES measures data in PIXELS
    
    // Create a graphics context with the target size measured in POINTS
    
    NSInteger widthInPoints, heightInPoints;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        
        CGFloat scale = [UIScreen mainScreen].scale;
        
        widthInPoints = width / scale;
        
        heightInPoints = height / scale;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
        
    }
    
    else {
        
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        
        widthInPoints = width;
        
        heightInPoints = height;
        
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
        
    }
    
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    
    // Flip the CGImage by rendering it to the flipped bitmap context
    
    // The size of the destination area is measured in POINTS
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    
    
    // Retrieve the UIImage from the current context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    UIGraphicsEndImageContext();
    
    // Clean up
    
    free(data);
    
    CFRelease(ref);
    
    CFRelease(colorspace);
    
    CGImageRelease(iref);
    
    return image;
}

- (void)destoryRender
{
    [displayLink invalidate];
    displayLink = nil;
}

#pragma mark - setter
- (void)setDelegate:(id<VideoDrawModelDelegate>)delegate
{
    _delegate = delegate;
    
    videoModel.delegate = delegate;
}

- (void)setOverture:(CGFloat)overture {
    _overture = overture;
    if (_overture > MAX_OVERTURE) {
        _overture = MAX_OVERTURE;
    }
    
    if (_overture < MIN_OVERTURE) {
        _overture = MIN_OVERTURE;
    }
}

- (CGFloat)scale {
    if (!_scale) {
        _scale = 1;
    }
    return _scale;
}

#pragma mark - getter
- (NSInteger)drawableWidth;
{
    GLint          backingWidth;
    
    glGetRenderbufferParameteriv(
                                 GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &backingWidth);
    
    return (NSInteger)backingWidth;
}

- (NSInteger)drawableHeight;
{
    GLint          backingHeight;
    
    glGetRenderbufferParameteriv(
                                 GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &backingHeight);
    
    return (NSInteger)backingHeight;
}

@end
