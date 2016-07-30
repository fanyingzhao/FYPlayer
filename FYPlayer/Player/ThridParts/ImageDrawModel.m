//
//  ImageDrawModel.m
//  Interactive
//
//  Created by fan on 16/6/29.
//  Copyright © 2016年 Abner. All rights reserved.
//

#import "ImageDrawModel.h"
#import "SampleApplicationShaderUtils.h"
#import "sphere.h"
#import "Texture.h"

@interface ImageDrawModel ()

@property (nonatomic, assign) GLuint shaderProgramID;
@property (nonatomic, assign) GLuint vertexHandle;
@property (nonatomic, assign) GLuint normalHandle;
@property (nonatomic, assign) GLuint textureCoordHandle;
@property (nonatomic, assign) GLuint texSampler2DHandle;
@property (nonatomic, assign) GLuint mvpMatrixHandle;

@end

@implementation ImageDrawModel


- (instancetype)initWithFileName:(NSString *)fileUrl context:(EAGLContext *)context
{
    if (self = [super init])
    {
        self.imageUrl = fileUrl;
        self.context = context;
        
        [EAGLContext setCurrentContext:self.context];

        [self initShader];
        [self initOpenGLImage];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image context:(EAGLContext *)context
{
    if (self = [super init])
    {
        self.context = context;
        
        [EAGLContext setCurrentContext:self.context];

        [self initShader];
        [self initOpenGLWithImage:image];
    }
    
    return self;
}

- (void)initOpenGLImage
{
    Texture* texture = [[Texture alloc] initWithImageFile:self.imageUrl];

    GLuint textureID;
    glGenTextures(1, &textureID);
    self.textureID = textureID;
    [texture setTextureID:textureID];
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [texture width], [texture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[texture pngData]);
}

- (void)initOpenGLWithImage:(UIImage*)image
{
    Texture* texture = [[Texture alloc] initWithImage:image];
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    self.textureID = textureID;
    [texture setTextureID:textureID];
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [texture width], [texture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[texture pngData]);
}

- (void)drawImage
{
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(self.shaderProgramID);

    glVertexAttribPointer(self.vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sphereVerts);
    glVertexAttribPointer(self.textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sphereTexCoords);
    
    glEnableVertexAttribArray(self.vertexHandle);
    glEnableVertexAttribArray(self.textureCoordHandle);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    glUniformMatrix4fv(self.mvpMatrixHandle, 1, GL_FALSE, self.modelViewProjectionMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    glDisableVertexAttribArray(self.vertexHandle);
    glDisableVertexAttribArray(self.textureCoordHandle);
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
}

#pragma mark - shader
- (void)initShader
{
    self.shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                                        fragmentShaderFileName:@"Simple.fragsh"];
    
    if (0 < self.shaderProgramID) {
        self.vertexHandle = glGetAttribLocation(self.shaderProgramID, "vertexPosition");
        self.normalHandle = glGetAttribLocation(self.shaderProgramID, "vertexNormal");
        self.textureCoordHandle = glGetAttribLocation(self.shaderProgramID, "vertexTexCoord");
        self.mvpMatrixHandle = glGetUniformLocation(self.shaderProgramID, "modelViewProjectionMatrix");
        
        self.texSampler2DHandle  = glGetUniformLocation(self.shaderProgramID,"texSampler2D");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}
@end
