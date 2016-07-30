//
//  NSString+FYAdd.h
//  FFKit
//
//  Created by fan on 16/7/9.
//  Copyright © 2016年 fan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FYAdd)

/**
 *  过滤非法字符
 *
 *  @param illegalStr 非法字符合集字符串
 *
 *  @return 过滤后通过 "" 拼接的字符
 */
- (NSString*)filterIllegalCharacter:(NSString*)illegalStr;
/**
 *  过滤非法字符
 *
 *  @param illegalStr 非法字符合集
 *  @param joinStr    连接字符
 *
 *  @return 过滤并连接后的字符串
 */
- (NSString*)filterIllegalCharacter:(NSString*)illegalStr joinStr:(NSString*)joinStr;

/**
 *  md516,32位加密
 *
 *  @return 加密后的字符串
 */
- (NSString*)md5With16Encoder;
- (NSString*)md5With32Encoder;
/**
 *  md5 16位加密后的文件名，相比普通加密，增加了文件的后缀（如果有）
 *
 *  @return 加密后的文件名
 */
- (NSString*)md5EncoderFilename;

- (BOOL)isValid;

@end
