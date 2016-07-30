//
//  NSString+FYAdd.m
//  FFKit
//
//  Created by fan on 16/7/9.
//  Copyright © 2016年 fan. All rights reserved.
//

#import "NSString+FYAdd.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (FYAdd)

- (NSString*)filterIllegalCharacter:(NSString *)illegalStr {
    return [self filterIllegalCharacter:illegalStr joinStr:@""];
}

- (NSString *)filterIllegalCharacter:(NSString *)illegalStr joinStr:(NSString *)joinStr {
    NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:illegalStr];
    return [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:joinStr];
}

- (NSString *)md5With16Encoder {
    if (![self isValid]) return nil;
    
    const char* str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString* md5Encoder = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],r[11], r[12], r[13], r[14], r[15]];
    
    return md5Encoder;
}

- (NSString *)md5With32Encoder {
    const char* str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH * 2];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString* md5Encoder = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],r[11], r[12], r[13], r[14], r[15],
                            r[16], r[17], r[18], r[19], r[20], r[21], r[22], r[23], r[24], r[25], r[26],r[27], r[28], r[29], r[30], r[131]];
    
    return md5Encoder;
}

- (BOOL)isValid {
    if (!self || [self isEqualToString:@""]) return NO;
    return YES;
}

- (NSString *)md5EncoderFilename {
    NSString* md5Encoder = [self md5With16Encoder];
    if ([[self pathExtension] isValid]) {
        return [md5Encoder stringByAppendingString:[NSString stringWithFormat:@".%@",[self pathExtension]]];
    }
    return md5Encoder;
}

@end
