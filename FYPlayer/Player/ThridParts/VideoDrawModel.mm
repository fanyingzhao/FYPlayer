//
//  VideoModel.m
//  Vuforia
//
//  Created by fan on 16/4/29.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "VideoDrawModel.h"
#import "SampleApplicationShaderUtils.h"
#import "sphere.h"
#import "GLRender.h"

@interface VideoDrawModel ()
{
    
}
@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;
@end

@implementation VideoDrawModel

- (instancetype)init
{
    if (self = [super init])
    {
        [self setUp];
    }
    
    return self;
}

- (void)dealloc
{
    [self cleanUpTextures];
}

#pragma mark - initialization
- (void)setUp
{
    [EAGLContext setCurrentContext:self.context];
    
    _preferredConversion = kColorConversion709;
    self.modelViewProjectionMatrix = GLKMatrix4Identity;

    [self initShader];
    
    if (!_videoTextureCache) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_videoTextureCache);
        if (err != noErr) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        }
    }
    
    [EAGLContext setCurrentContext:self.context];
}


- (void)initShader
{
    [EAGLContext setCurrentContext:self.context];

    self.shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Shader.vsh"
                                                                   fragmentShaderFileName:@"Shader.fsh"];
    
    if (0 < self.shaderProgramID) {
        self.vertexHandle = glGetAttribLocation(self.shaderProgramID, "position");
        self.textureCoordHandle = glGetAttribLocation(self.shaderProgramID, "texCoord");
        self.mvpMatrixHandle = glGetUniformLocation(self.shaderProgramID, "modelViewProjectionMatrix");
        
        videoUniforms[UNIFORM_Y] = glGetUniformLocation(self.shaderProgramID, "SamplerY");
        videoUniforms[UNIFORM_UV] = glGetUniformLocation(self.shaderProgramID, "SamplerUV");
        videoUniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(self.shaderProgramID, "colorConversionMatrix");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (instancetype)initWithContext:(EAGLContext *)context
{
    if (self = [super init])
    {
        self.context = context;
        
        [self setUp];

    }
    
    return self;
}

#pragma mark - draw
- (void)drawVideo
{
    [EAGLContext setCurrentContext:self.context];
    
    glUseProgram(self.shaderProgramID);
    
    glUniform1i(videoUniforms[UNIFORM_Y], 0);
    glUniform1i(videoUniforms[UNIFORM_UV], 1);
    glUniformMatrix3fv(videoUniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getVideoBufferPixel)])
    {
        // 绑定视频纹理
        CVPixelBufferRef pixelBuffer = [self.delegate getVideoBufferPixel];
        
        CVReturn err;
        if (NULL != pixelBuffer)
        {
            int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
            int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
            self.videoWidth = frameWidth;
            self.videoHeight = frameHeight;
            
            if (!_videoTextureCache) {
                NSLog(@"No video texture cache");
                return;
            }
            
            [self cleanUpTextures];
            
            // Y-plane
            glActiveTexture(GL_TEXTURE0);
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               _videoTextureCache,
                                                               pixelBuffer,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               GL_RED_EXT,
                                                               frameWidth,
                                                               frameHeight,
                                                               GL_RED_EXT,
                                                               GL_UNSIGNED_BYTE,
                                                               0,
                                                               &_lumaTexture);
            if (err) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
            
            glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            // UV-plane.
            glActiveTexture(GL_TEXTURE1);
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               _videoTextureCache,
                                                               pixelBuffer,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               GL_RG_EXT,
                                                               frameWidth / 2,
                                                               frameHeight / 2,
                                                               GL_RG_EXT,
                                                               GL_UNSIGNED_BYTE,
                                                               1,
                                                               &_chromaTexture);
            if (err) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
            
            glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            [self drawShapeVideo];
            
            CFRelease(pixelBuffer);
        }
        else
        {
            static int i = 0;
            if (i == 20)
            {
                NSLog(@"没有视频数据");
            }
            
            if (_lumaTexture && _chromaTexture) {
                
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                glActiveTexture(GL_TEXTURE1);
                glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                [self drawShapeVideo];
            }
        }
    }
}

- (void)drawShapeVideo
{
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    

    glVertexAttribPointer(self.vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sphereVerts);
    glVertexAttribPointer(self.textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sphereTexCoords);

    glEnableVertexAttribArray(self.vertexHandle);
    glEnableVertexAttribArray(self.textureCoordHandle);

    // 调整画布尺寸与视频尺寸匹配
    CGFloat proportion = self.videoWidth / self.videoHeight;
    CGFloat widthProportion = self.videoWidth / self.render.drawableWidth;
    CGFloat heightProportion = self.videoHeight / self.render.drawableHeight;
    
    if (self.render.isFullscreenMode)
    {
        // 全屏模式,横向视频调整比例
        if (self.videoWidth > self.videoHeight)
        {
            // 横向视频
//            self.modelViewProjectionMatrix = GLKMatrix4Scale(self.modelViewProjectionMatrix, 1, 1 / proportion, 1);
        }
        else
        {
            // 纵向视频
            self.modelViewProjectionMatrix = GLKMatrix4RotateZ(self.modelViewProjectionMatrix, M_PI_2);
//            self.modelViewProjectionMatrix = GLKMatrix4Scale(self.modelViewProjectionMatrix, 1, 1, 1);
        }
    }
    else
    {
        if (self.videoWidth > self.videoHeight)
        {
            // 横向视频
            
//            // 适配视频尺寸
//            if (widthProportion < heightProportion)
//            {
//                // 视频宽度根据高度适配，高度为1，宽度调整
//                self.modelViewProjectionMatrix = GLKMatrix4Scale(self.modelViewProjectionMatrix, proportion, 1, 1);
//            }
//            else
//            {
//                // 视频高度根据宽度调整，宽度为 1
//                self.modelViewProjectionMatrix = GLKMatrix4Scale(self.modelViewProjectionMatrix, 1, proportion, 1);
//            }
        }
        else
        {
            // 纵向视频
            self.modelViewProjectionMatrix = GLKMatrix4RotateZ(self.modelViewProjectionMatrix, M_PI_2);

//            // 适配视频尺寸
//            if (widthProportion < heightProportion)
//            {
//                // 视频宽度根据高度适配，高度为1，宽度调整
//                self.modelViewProjectionMatrix = GLKMatrix4Scale(self.modelViewProjectionMatrix, proportion, 1, 1);
//            }
//            else
//            {
//                // 视频高度根据宽度调整，宽度为 1
//                self.modelViewProjectionMatrix = GLKMatrix4Scale(self.modelViewProjectionMatrix, 1,  proportion, 1);
//            }
        }
    }
    
    glUniformMatrix4fv(self.mvpMatrixHandle, 1, GL_FALSE, self.modelViewProjectionMatrix.m);

    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    glDisableVertexAttribArray(self.vertexHandle);
    glDisableVertexAttribArray(self.textureCoordHandle);
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
}

#pragma mark texture cleanup
- (void)cleanUpTextures
{
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

#pragma mark - getter

@end


