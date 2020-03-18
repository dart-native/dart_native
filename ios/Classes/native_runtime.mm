#import "native_runtime.h"
#include <stdlib.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "DNBlockWrapper.h"
#import "DNFFIHelper.h"
#import "DNMethodIMP.h"
#import "DNObjectDealloc.h"
#import "NSThread+DartNative.h"

NSMethodSignature *
native_method_signature(Class cls, SEL selector) {
    if (!selector) {
        return nil;
    }
    NSMethodSignature *signature = [cls instanceMethodSignatureForSelector:selector];
    return signature;
}

void
native_signature_encoding_list(NSMethodSignature *signature, const char **typeEncodings) {
    if (!signature || !typeEncodings) {
        return;
    }
    
    for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
        *(typeEncodings + i - 1) = [signature getArgumentTypeAtIndex:i];
    }
    *typeEncodings = signature.methodReturnType;
}

BOOL
native_add_method(id target, SEL selector, char *types, void *callback) {
    Class cls = object_getClass(target);
    NSString *selName = [NSString stringWithFormat:@"dart_native_%@", NSStringFromSelector(selector)];
    SEL key = NSSelectorFromString(selName);
    DNMethodIMP *imp = objc_getAssociatedObject(cls, key);
    // Existing implemention can't be replaced. Flutter hot-reload must also be well handled.
    if (!imp && [target respondsToSelector:selector]) {
        return NO;
    }
    if (types != NULL) {
        DNMethodIMP *methodIMP = [[DNMethodIMP alloc] initWithTypeEncoding:types callback:callback]; // DNMethodIMP always exists.
        class_replaceMethod(cls, selector, [methodIMP imp], types);
        objc_setAssociatedObject(cls, key, methodIMP, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return YES;
    }
    return NO;
}

char *
native_protocol_method_types(Protocol *proto, SEL selector) {
    struct objc_method_description description = protocol_getMethodDescription(proto, selector, YES, YES);
    if (description.types == NULL) {
        description = protocol_getMethodDescription(proto, selector, NO, YES);
    }
    return description.types;
}

Class
native_get_class(const char *className, Class baseClass) {
    Class result = objc_getClass(className);
    if (result) {
        return result;
    }
    if (!baseClass) {
        baseClass = NSObject.class;
    }
    result = objc_allocateClassPair(baseClass, className, 0);
    objc_registerClassPair(result);
    return result;
}

void *
_mallocReturnStruct(NSMethodSignature *signature) {
    const char *type = signature.methodReturnType;
    NSUInteger size;
    DNSizeAndAlignment(type, &size, NULL, NULL);
    void *result = malloc(size);
    return result;
}

void
_fillArgsToInvocation(NSMethodSignature *signature, void **args, NSInvocation *invocation, NSUInteger offset) {
    for (NSUInteger i = offset; i < signature.numberOfArguments; i++) {
        const char *argType = [signature getArgumentTypeAtIndex:i];
        NSUInteger argsIndex = i - offset;
        if (argType[0] == '*') {
            // Copy CString to NSTaggedPointerString and transfer it's lifecycle to ARC. Orginal pointer will be freed after function returning.
            const char *temp = [NSString stringWithUTF8String:(const char *)args[argsIndex]].UTF8String;
            if (temp) {
                args[argsIndex] = (void *)temp;
            }
        }
        if (argType[0] == '{') {
            // Already put struct in pointer on Dart side.
            [invocation setArgument:args[argsIndex] atIndex:i];
        } else {
            [invocation setArgument:&args[argsIndex] atIndex:i];
        }
    }
}

void *
native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, dispatch_queue_t queue, void **args, BOOL waitUntilDone) {
    if (!object || !selector || !signature) {
        return NULL;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = object;
    invocation.selector = selector;
    _fillArgsToInvocation(signature, args, invocation, 2);
    if (queue != NULL) {
        // Return immediately.
        if (!waitUntilDone) {
            dispatch_async(queue, ^{
                [invocation invoke];
            });
            return nil;
        }
        // Same queue
        if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
            [invocation invoke];
        } else {
            dispatch_sync(queue, ^{
                [invocation invoke];
            });
        }
    } else {
        [invocation invoke];
    }
    void *result = NULL;
    const char returnType = signature.methodReturnType[0];
    if (signature.methodReturnLength > 0) {
        if (returnType == '{') {
            result = _mallocReturnStruct(signature);
            [invocation getReturnValue:result];
        } else {
            [invocation getReturnValue:&result];
            if (returnType == '@') {
                [DNObjectDealloc attachHost:(__bridge id)result];
            }
        }
    }
    return result;
}

void *
native_block_create(char *types, void *callback) {
    DNBlockWrapper *wrapper = [[DNBlockWrapper alloc] initWithTypeString:types callback:callback];
    return (__bridge void *)wrapper;
}

void *
native_block_invoke(void *block, void **args) {
    const char *typeString = DNBlockTypeEncodeString((__bridge id)block);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    _fillArgsToInvocation(signature, args, invocation, 1);
    [invocation invokeWithTarget:(__bridge id)block];
    void *result = NULL;
    const char returnType = signature.methodReturnType[0];
    if (signature.methodReturnLength > 0) {
        if (returnType == '{') {
            result = _mallocReturnStruct(signature);
            [invocation getReturnValue:result];
        } else {
            [invocation getReturnValue:&result];
            if (returnType == '@') {
                [DNObjectDealloc attachHost:(__bridge id)result];
            }
        }
    }
    return result;
}

// Use pointer as key of encoding string cache (on dart side).
static const char *typeList[18] = {"sint8", "sint16", "sint32", "sint64", "uint8", "uint16", "uint32", "uint64", "float32", "float64", "object", "class", "selector", "block", "char *", "void", "ptr", "bool"};

#define SINT(type) do { \
    if (str[0] == @encode(type)[0]) \
    { \
        size_t size = sizeof(type); \
        if (size == 1) { \
            return typeList[0]; \
        } else if (size == 2) { \
            return typeList[1]; \
        } else if (size == 4) { \
            return typeList[2]; \
        } else if (size == 8) { \
            return typeList[3]; \
        } else { \
            NSLog(@"Unknown size for type %s", #type); \
            abort(); \
        } \
    } \
} while(0)

#define UINT(type) do { \
    if (str[0] == @encode(type)[0]) \
    { \
        size_t size = sizeof(type); \
        if (size == 1) { \
            return typeList[4]; \
        } else if (size == 2) { \
            return typeList[5]; \
        } else if (size == 4) { \
            return typeList[6]; \
        } else if (size == 8) { \
            return typeList[7]; \
        } else { \
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
    if (str[0] == @encode(type)[0]) \
    return name; \
} while(0)

#define PTR(type) COND(type, typeList[16])

const char *
native_type_encoding(const char *str) {
    if (!str || strlen(str) == 0) {
        return NULL;
    }
    
    COND(_Bool, typeList[17]);
    SINT(signed char);
    UINT(unsigned char);
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
    int argCount = DNTypeCount(str) - startIndex;
    const char **argTypes = (const char **)malloc(sizeof(char *) * argCount);
    
    int i = -startIndex;
    while(str && *str)
    {
        const char *next = DNSizeAndAlignment(str, NULL, NULL, NULL);
        if (i >= 0 && i < argCount) {
            const char *argType = native_type_encoding(str);
            if (argType) {
                argTypes[i] = argType;
            } else {
                if (count) {
                    *count = -1;
                }
                free(argTypes);
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
native_struct_encoding(const char *encoding) {
    NSUInteger size, align;
    long length;
    DNSizeAndAlignment(encoding, &size, &align, &length);
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

dispatch_queue_main_t
_dispatch_get_main_queue(void) {
    return dispatch_get_main_queue();
}

void
native_mark_autoreleasereturn_object(id object) {
    int64_t address = (int64_t)object;
    [NSThread.currentThread dn_performWaitingUntilDone:YES block:^{
        NSThread.currentThread.threadDictionary[@(address)] = object;
    }];
}
