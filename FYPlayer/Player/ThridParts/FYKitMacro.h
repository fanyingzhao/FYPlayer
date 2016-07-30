//
//  FYKitMacro.h
//  FFKit
//
//  Created by fan on 16/6/28.
//  Copyright © 2016年 fan. All rights reserved.
//

#ifndef FYKitMacro_h
#define FYKitMacro_h

/*---------字符串-----------------------*/
#define FYString(format, ...)   [NSString stringWithFormat:format, ##__VA_ARGS__]

/*---------输出-----------------------*/
#ifdef DEBUG
#define FYLog(format, ...) NSLog((@"<%@ %@ %d>  " format), [[NSString stringWithFormat:@"%s",__FILE__] lastPathComponent], [[[NSString stringWithFormat:@"%s",__FUNCTION__] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ]"]] objectAtIndex:1], __LINE__,##__VA_ARGS__)
#else
#define FYLog(format, ...)
#endif

/*---------断言-----------------------*/
#define FYAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_AGRS__)
#define FYCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define FYAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define FYCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)

#define FYAssertMainThread NSAssert([NSThread isMainThread],@"必须在主线程上调用")
#define FYCAssertMainThread NSCAssert([NSThread isMainThread],@"必须在主线程上调用")

/*---------提示信息-----------------------*/
#ifdef DEBUG
#define FYAlertMsg(msg) \
UIView* view = [[UIView alloc] init];\
if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){\
    view.frame = [UIScreen mainScreen].bounds;\
}else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {\
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);\
}\
view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];\
UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 100, CGRectGetWidth(view.bounds) - 20 * 2, CGRectGetHeight(view.bounds) - 100 * 2)];\
textView.text = msg;\
textView.editable = NO;\
textView.font = [UIFont systemFontOfSize:15];\
textView.textColor = [UIColor whiteColor];\
textView.backgroundColor = [UIColor clearColor];\
[view addSubview:textView];\
[[UIApplication sharedApplication].windows.lastObject addSubview:view];
#else
#define FYAlertMsg(msg)
#endif


/*---------指针-----------------------*/
#ifdef DEBUG
#define ext_keywordify autoreleasepool {}
#else
#define ext_keywordify try {} @catch (...) {}
#endif

#define weakify(self) \
ext_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wunused-variable\"") \
__attribute__((objc_ownership(weak))) __typeof__(self) self_weak_ = (self)\
_Pragma("clang diagnostic pop")

#define strongify(self) \
ext_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wunused-variable\"") \
__attribute__((objc_ownership(strong))) __typeof__(self) self = (self_weak_)\
_Pragma("clang diagnostic pop")


/*---------编译-----------------------*/
#ifdef __culpsplus
#define FY_EXTERN_C_BEGIN   extern "C" {
#define FY_EXTERN_C_END     }
#else
#define FY_EXTERN_C_BEGIN
#define FY_EXTERN_C_END
#endif

/*---------简化方法-----------------------*/
#define executeOnMain(block)    if ([NSThread isMainThread]) {\
    block\
}else {\
    dispatch_async(dispatch_get_main_queue(), ^{\
        block;\
    });\
}

#define Appdelegate         [UIApplication sharedApplication].delegate

/*---------设备信息-----------------------*/
#define UIDEVICE_SCREEN_WIDTH          [UIScreen mainScreen].bounds.size.width                         // 屏幕宽度
#define UIDEVICE_SCREEN_HEIGHT         [UIScreen mainScreen].bounds.size.height                        // 屏幕高度
#define UIDEVICE_LANDSPACE_WIDTH       MAX(UIDEVICE_SCREEN_WIDTH, UIDEVICE_SCREEN_HEIGHT)                    // 横屏宽度
#define UIDEVICE_LANDSPACE_HEIGHT      MIN(UIDEVICE_SCREEN_WIDTH, UIDEVICE_SCREEN_HEIGHT)                    // 横屏高度



/*---------颜色-----------------------*/
#define UICOLOR_RGB(r, g, b)               [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0]
#define UICOLOR_RGB_ALPHA(r, g, b, alpha)      [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:alpha]
#define UICOLOR_HEX(hex)                   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                                          blue:((float)(rgbValue & 0xFF)) 255.0 alpha:1.0]
#define UICOLOR_HEX_ALPHA(hex, alpha)             [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                                          blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha]





#endif /* FYKitMacro_h */
