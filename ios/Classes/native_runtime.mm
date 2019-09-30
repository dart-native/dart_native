#import "native_runtime.h"
#include <stdlib.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

extern "C" __attribute__((visibility("default"))) __attribute((used))
void *
native_method_imp(const char *cls_str, const char *selector_str, bool isClassMethod)
{
    Class cls = isClassMethod ? objc_getMetaClass(cls_str) : objc_getClass(cls_str);
    SEL selector = sel_registerName(selector_str);
    IMP imp = class_getMethodImplementation(cls, selector);
    return (void *)imp;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
void *
native_instance_invoke(void *instance, const char *selector_str, void *arguments) {
    id object = (__bridge id)instance;
    SEL selector = sel_registerName(selector_str);
    IMP imp = [object methodForSelector:selector];
    
    
    
    return ((void * (*)(id, SEL))imp)(object, selector);
}
