//
//  VideoModel.h
//  Vuforia
//
//  Created by fan on 16/4/29.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

typedef NS_ENUM(NSInteger, PlayModel) {
    PlayModelNormal,                     // 普通视频
    PlayModelPanorama,                   // 全景视频
    PlayModelVRPanorama,                 // 双屏全景视频
    PlayModelImage,                      // 图片
};


@protocol VideoDrawModelDelegate <NSObject>
@optional

- (CVPixelBufferRef)getVideoBufferPixel;

@end

static const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

enum {
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_COLOR_CONVERSION_MATRIX,
    NUM_UNIFORMS
};

@class GLRender;
@interface VideoDrawModel : NSObject
{
    const GLfloat *_preferredConversion;

    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    GLint videoUniforms[NUM_UNIFORMS];
}

@property (nonatomic, assign) GLuint shaderProgramID;
@property (nonatomic, assign) GLuint vertexHandle;
@property (nonatomic, assign) GLuint normalHandle;
@property (nonatomic, assign) GLuint textureCoordHandle;
@property (nonatomic, assign) GLuint mvpMatrixHandle;

@property (nonatomic, assign) GLKMatrix4 modelViewProjectionMatrix;
@property (nonatomic, strong) EAGLContext* context;


@property (nonatomic, weak) id<VideoDrawModelDelegate> delegate;
@property (nonatomic, weak) GLRender* render;


/**
 *  两个方法一起使用
 */
- (instancetype)initWithContext:(EAGLContext*)context;


- (void)cleanUpTextures;

- (void)drawVideo;

- (void)initShader;
@end

