//
//  DNException.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/8.
//

#import "DNException.h"
#import <objc/runtime.h>
#import <objc/message.h>

#if !__has_feature(objc_arc)
#error
#endif

NSString * const DNClassNotFoundExceptionReason = @"Class %@ not found.";
NSExceptionName const DNClassNotFoundException = @"ClassNotFoundException";

void DartNativeSetThrowException(bool canThrow) {
    static Class targetClass = objc_getClass("DNInterfaceRegistry");
    static SEL selector = NSSelectorFromString(@"setExceptionEnabled:");
    if (!targetClass || !selector) {
        if (canThrow) {
            throw [NSException exceptionWithName:DNClassNotFoundException
                                          reason:DNClassNotFoundExceptionReason
                                        userInfo:nil];
        }
    }
    ((void(*)(Class, SEL, BOOL))objc_msgSend)(targetClass, selector, canThrow);
}

bool DartNativeCanThrowException() {
    static Class targetClass = objc_getClass("DNInterfaceRegistry");
    static SEL selector = NSSelectorFromString(@"isExceptionEnabled");
    if (!targetClass || !selector) {
        return false;
    }
    return ((BOOL(*)(Class, SEL))objc_msgSend)(targetClass, selector);
}
