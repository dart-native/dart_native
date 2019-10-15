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
NSMethodSignature *
native_method_signature(id object, SEL selector, const char **typeEncodings) {
    if (!object || !selector || !typeEncodings) {
        return NULL;
    }
    NSMethodSignature *signature = [object methodSignatureForSelector:selector];
    for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
        *(typeEncodings + i - 1) = [signature getArgumentTypeAtIndex:i];
    }
    *typeEncodings = signature.methodReturnType;
    return signature;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
void *
native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, void **args) {
    if (!object || !selector || !signature) {
        return NULL;
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
//        if (signature.methodReturnType[0] == '@') {
//            NSObject *resultObj = nil;
//            [invocation getReturnValue:&resultObj];
//            NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)resultObj));
//            return (__bridge void *)resultObj;
//        }
        [invocation getReturnValue:&result];
    }
    
//    NSObject *resultObj = (__bridge id)result;
    if (result) {
        NSLog(@"instance_invoke Retain count is %ld", CFGetRetainCount((CFTypeRef)result));
    }
    return result;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char *
native_type_encoding(const char *str) {
    if (!str) {
        return NULL;
    }
    #define SINT(type) do { \
        if(str[0] == @encode(type)[0]) \
        { \
            if(sizeof(type) == 1) \
                return "sint8"; \
            else if(sizeof(type) == 2) \
                return "sint16"; \
            else if(sizeof(type) == 4) \
                return "sint32"; \
            else if(sizeof(type) == 8) \
                return "sint64"; \
            else \
            { \
                NSLog(@"Unknown size for type %s", #type); \
                abort(); \
            } \
        } \
    } while(0)
    
    #define UINT(type) do { \
        if(str[0] == @encode(type)[0]) \
        { \
            if(sizeof(type) == 1) \
                return "uint8"; \
            else if(sizeof(type) == 2) \
                return "uint16"; \
            else if(sizeof(type) == 4) \
                return "uint32"; \
            else if(sizeof(type) == 8) \
                return "uint64"; \
            else \
            { \
                NSLog(@"Unknown size for type %s", #type); \
                abort(); \
            } \
        } \
    } while(0)
    
    #define INT(type) do { \
        SINT(type); \
        UINT(unsigned type); \
    } while(0)
    
    #define COND(type, name) do { \
        if(str[0] == @encode(type)[0]) \
        return #name; \
    } while(0)
    
    #define PTR(type) COND(type, pointer)
    
    SINT(_Bool);
    INT(char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    COND(float, float32);
    COND(double, float64);
    
    COND(id, object);
    COND(Class, class);
    COND(SEL, selector);
    PTR(void *);
    COND(char *, char *);
    
    COND(void, void);
    
    // Ignore Method Encodings
    switch (*str) {
        case 'r':
        case 'R':
        case 'n':
        case 'N':
        case 'o':
        case 'O':
        case 'V':
            return native_type_encoding(str + 1);
    }
    
    // Struct Type Encodings
//    if (*str == '{') {
//    }
    
    NSLog(@"Unknown encode string %s", str);
    return str;
}
