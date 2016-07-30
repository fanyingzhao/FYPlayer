//
//  GLRender.h
//  JFPlayer
//
//  Created by fan on 16/6/2.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "VideoDrawModel.h"
#import "ImageDrawModel.h"

@interface GLRender : NSObject
{
    GLuint        defaultFrameBuffer;
    GLuint        colorRenderBuffer;
    GLuint        depthRenderBuffer;
    GLint         drawableWidth;
    GLint         drawableHeight;
    
    CADisplayLink     *displayLink;
    NSInteger         preferredFramesPerSecond;
}
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, weak) CAEAGLLayer* layer;
@property (nonatomic, readonly) NSInteger drawableWidth;
@property (nonatomic, readonly) NSInteger drawableHeight;

@property (nonatomic, assign) CGFloat overture;

@property (nonatomic, assign) BOOL isFullscreenMode;                                // 当前是否是全屏播放状态
@property (nonatomic, assign) PlayModel playModel;
@property (nonatomic, assign) CGFloat scale;                                        // 缩放值

@property (nonatomic, weak) id<VideoDrawModelDelegate> delegate;


- (instancetype)initWithLayer:(CAEAGLLayer*)layer;
- (void)initImageModel:(NSString*)imageUrl;
- (void)initWithImage:(UIImage*)image;

- (void)initFrameBuffer;
- (void)deleteFrameBuffer;

- (void)fingerStart;
- (void)fingerRotationX:(CGFloat)fingerX fingerY:(CGFloat)fingerY;
- (void)fingerEnd;

- (void)startRender;
- (void)endRender;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (UIImage*)snapVideoImage;
- (void)destoryRender;

@end
