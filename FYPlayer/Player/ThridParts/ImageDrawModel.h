//
//  ImageDrawModel.h
//  Interactive
//
//  Created by fan on 16/6/29.
//  Copyright © 2016年 Abner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ImageDrawModel : NSObject

@property (nonatomic, assign, readonly) GLuint shaderProgramID;
@property (nonatomic, assign, readonly) GLuint vertexHandle;
@property (nonatomic, assign, readonly) GLuint normalHandle;
@property (nonatomic, assign, readonly) GLuint textureCoordHandle;
@property (nonatomic, assign, readonly) GLuint texSampler2DHandle;
@property (nonatomic, assign, readonly) GLuint mvpMatrixHandle;

@property (nonatomic, assign) GLKMatrix4 modelViewProjectionMatrix;

@property (nonatomic, strong) EAGLContext* context;
@property (nonatomic, copy) NSString* imageUrl;
@property (nonatomic, assign) GLuint textureID;

- (instancetype)initWithFileName:(NSString *)fileUrl context:(EAGLContext *)context;
- (instancetype)initWithImage:(UIImage*)image context:(EAGLContext*)context;

- (void)drawImage;

@end
