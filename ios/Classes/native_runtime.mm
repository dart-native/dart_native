#import "native_runtime.h"
#include <stdlib.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "DOBlockWrapper.h"
#import "Wrapper-Interface.h"

void *
native_method_imp(const char *cls_str, const char *selector_str, bool isClassMethod) {
    Class cls = isClassMethod ? objc_getMetaClass(cls_str) : objc_getClass(cls_str);
    SEL selector = sel_registerName(selector_str);
    IMP imp = class_getMethodImplementation(cls, selector);
    return (void *)imp;
}

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

void *
native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, void **args) {
    if (!object || !selector || !signature) {
        return NULL;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = object;
    invocation.selector = selector;
    
    for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
        const char *argType = [signature getArgumentTypeAtIndex:i];
        if (argType[0] == '{') {
            [invocation setArgument:args[i - 2] atIndex:i];
        }
        else {
            [invocation setArgument:&args[i - 2] atIndex:i];
        }
    }
    [invocation invoke];
    void *result = NULL;
    if (signature.methodReturnLength > 0) {
        [invocation getReturnValue:&result];
        const char returnType = signature.methodReturnType[0];
        if (result && returnType == '@') {
            NSString *selString = NSStringFromSelector(selector);
            if (!([selString hasPrefix:@"new"] ||
                [selString hasPrefix:@"alloc"] ||
                [selString hasPrefix:@"copy"] ||
                [selString hasPrefix:@"mutableCopy"])) {
                [(id)result retain];
            }
        }
        else if (returnType == '{') {
            const char *temp = signature.methodReturnType;
            int index = 0;
            while (temp && *temp && *temp != '=') {
                temp++;
                index++;
            }
            NSString *structTypeEncoding = [NSString stringWithUTF8String:signature.methodReturnType];
            NSString *structName = [structTypeEncoding substringWithRange:NSMakeRange(1, index - 1)];
            #define HandleStruct(struct) \
            if ([structName isEqualToString:@#struct]) { \
                void *structAddr = malloc(sizeof(struct)); \
                memcpy(structAddr, &result, sizeof(struct)); \
                return structAddr; \
            }
            HandleStruct(CGSize)
            HandleStruct(CGPoint)
            HandleStruct(CGVector)
            HandleStruct(CGRect)
            HandleStruct(NSRange)
            NSCAssert(NO, @"Can't handle struct type:%@", structName);
        }
    }
    return result;
}

void *
block_create(char *types, void *callback) {
    DOBlockWrapper *wrapper = [[[DOBlockWrapper alloc] initWithTypeString:types callback:callback] autorelease];
    return wrapper;
}

void *
block_invoke(void *block, void **args) {
    const char *typeString = DOBlockTypeEncodeString((id)block);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    for (NSUInteger idx = 1; idx < signature.numberOfArguments; idx++) {
        [invocation setArgument:&args[idx - 1] atIndex:idx];
    }
    [invocation invokeWithTarget:(id)block];
    void *result = NULL;
    if (signature.methodReturnLength > 0) {
        [invocation getReturnValue:&result];
        if (result && signature.methodReturnType[0] == '@') {
            [(id)result retain];
        }
    }
    return result;
}

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
    
    #define PTR(type) COND(type, ptr)
    
    SINT(_Bool);
    INT(char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    COND(float, float32);
    COND(double, float64);
    
    if (strcmp(str, "@?") == 0) {
        return "block";
    }
    
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
    if (*str == '{') {
        return native_struct_encoding(str);
    }
    
    NSLog(@"Unknown encode string %s", str);
    return str;
}

const char **
native_types_encoding(const char *str, int *count, int startIndex) {
    int argCount = DOTypeCount(str) - startIndex;
    const char **argTypes = (const char **)malloc(sizeof(char *) * argCount);
    
    int i = -startIndex;
    while(str && *str)
    {
        const char *next = DOSizeAndAlignment(str, NULL, NULL, NULL);
        if (i >= 0 && i < argCount) {
            const char *argType = native_type_encoding(str);
            if (argType) {
                argTypes[i] = argType;
            }
            else {
                if (count) {
                    *count = -1;
                }
                return nil;
            }
        }
        i++;
        str = next;
    }
    
    if (count) {
        *count = argCount;
    }
    
    return argTypes;
}

const char *
native_struct_encoding(const char *encoding)
{
    NSUInteger size, align;
    long length;
    DOSizeAndAlignment(encoding, &size, &align, &length);
    NSString *str = [NSString stringWithUTF8String:encoding];
    const char *temp = [str substringWithRange:NSMakeRange(0, length)].UTF8String;
    int structNameLength = 0;
    // cut "struct="
    while (temp && *temp && *temp != '=') {
        temp++;
        structNameLength++;
    }
    int elementCount = 0;
    const char **elements = native_types_encoding(temp + 1, &elementCount, 0);
    if (!elements) {
        return nil;
    }
    NSMutableString *structType = [NSMutableString stringWithFormat:@"%@", [str substringToIndex:structNameLength + 1]];
    for (int i = 0; i < elementCount; i++) {
        if (i != 0) {
            [structType appendString:@","];
        }
        [structType appendFormat:@"%@", [NSString stringWithUTF8String:elements[i]]];
    }
    [structType appendString:@"}"];
    return structType.UTF8String;
}

bool
LP64() {
#if defined(__LP64__) && __LP64__
    return true;
#else
    return false;
#endif
}

bool
NS_BUILD_32_LIKE_64() {
#if defined(NS_BUILD_32_LIKE_64) && NS_BUILD_32_LIKE_64
    return true;
#else
    return false;
#endif
}
