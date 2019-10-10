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
native_instance_invoke(void *instance, const char *selector_str, void **args) {
    id object = (__bridge id)instance;
    SEL selector = sel_registerName(selector_str);

    NSMethodSignature *signature = [object methodSignatureForSelector:selector];
    if (!signature) {
        return nullptr;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = object;
    invocation.selector = selector;
    
    for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
        [invocation setArgument:&args[i - 2] atIndex:i];
    }
    [invocation invoke];
    void *result = NULL;
    if (signature.methodReturnLength > 0) {
        [invocation getReturnValue:&result];
    }
    return result;
}
