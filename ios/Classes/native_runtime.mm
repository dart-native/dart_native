#import "native_runtime.h"
#include <stdlib.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "DOBlockWrapper.h"
#import "DOFFIHelper.h"
#import "DOMethodIMP.h"
#import "DOObjectDealloc.h"

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

NSMutableArray<DOMethodIMP *> *_methodIMPList = [NSMutableArray array];

BOOL
native_add_method(id target, SEL selector, Protocol *proto, void *callback) {
    Class cls = object_getClass(target);
    if ([target respondsToSelector:selector]) {
        return NO;
    }
    struct objc_method_description description = protocol_getMethodDescription(proto, selector, YES, YES);
    if (description.types == NULL) {
        description = protocol_getMethodDescription(proto, selector, NO, YES);
    }
    if (description.types != NULL) {
        DOMethodIMP *methodIMP = [[DOMethodIMP alloc] initWithTypeEncoding:description.types callback:callback]; // DOMethodIMP always exists.
        [_methodIMPList addObject:methodIMP];
        class_replaceMethod(cls, selector, [methodIMP imp], description.types);
        return YES;
    }
    return NO;
}

Class
native_get_class(const char *className, Class baseClass) {
    Class result = objc_getClass(className);
    if (result) {
        return result;
    }
    else if (baseClass) {
        result = objc_allocateClassPair(baseClass, className, 0);
        objc_registerClassPair(result);
    }
    return result;
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
                [DOObjectDealloc attachHost:(__bridge id)result];
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
native_block_create(char *types, void *callback) {
    DOBlockWrapper *wrapper = [[DOBlockWrapper alloc] initWithTypeString:types callback:callback];
    return (__bridge void *)wrapper;
}

void *
native_block_invoke(void *block, void **args) {
    const char *typeString = DOBlockTypeEncodeString((__bridge id)block);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    for (NSUInteger idx = 1; idx < signature.numberOfArguments; idx++) {
        [invocation setArgument:&args[idx - 1] atIndex:idx];
    }
    [invocation invokeWithTarget:(__bridge id)block];
    void *result = NULL;
    if (signature.methodReturnLength > 0) {
        [invocation getReturnValue:&result];
        if (result && signature.methodReturnType[0] == '@') {
//            [(id)result retain];
        }
    }
    return result;
}

const char *
native_type_encoding(const char *str) {
    if (!str) {
        return NULL;
    }
    static const char *typeList[18] = {"sint8", "sint16", "sint32", "sint64", "uint8", "uint16", "uint32", "uint64", "float32", "float64", "object", "class", "selector", "block", "char *", "void", "ptr", "bool"};
    
    #define SINT(type) do { \
        if(str[0] == @encode(type)[0]) \
        { \
            size_t size = sizeof(type); \
            if(size == 1) \
                return typeList[0]; \
            else if(size == 2) \
                return typeList[1]; \
            else if(size == 4) \
                return typeList[2]; \
            else if(size == 8) \
                return typeList[3]; \
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
            size_t size = sizeof(type); \
            if(size == 1) \
                return typeList[4]; \
            else if(size == 2) \
                return typeList[5]; \
            else if(size == 4) \
                return typeList[6]; \
            else if(size == 8) \
                return typeList[7]; \
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
        return name; \
    } while(0)
    
    #define PTR(type) COND(type, typeList[16])
    
    COND(_Bool, typeList[17]);
    INT(char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    COND(float, typeList[8]);
    COND(double, typeList[9]);
    
    if (strcmp(str, "@?") == 0) {
        return typeList[13];
    }
    
    COND(id, typeList[10]);
    COND(Class, typeList[11]);
    COND(SEL, typeList[12]);
    PTR(void *);
    COND(char *, typeList[14]);
    COND(void, typeList[15]);
    
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
    free(elements);
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
