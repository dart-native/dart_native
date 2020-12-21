#import "native_runtime.h"
#include <stdlib.h>
#include <functional>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "DNBlockWrapper.h"
#import "DNFFIHelper.h"
#import "DNMethodIMP.h"
#import "DNObjectDealloc.h"
#import "NSThread+DartNative.h"
#import "DNPointerWrapper.h"
#import "DNInvocation.h"

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
        DNMethodIMP *methodIMP = [[DNMethodIMP alloc] initWithTypeEncoding:types callback:(NativeMethodCallback)callback]; // DNMethodIMP always exists.
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
native_get_class(const char *className, Class superclass) {
    Class result = objc_getClass(className);
    if (result) {
        return result;
    }
    if (!superclass) {
        superclass = NSObject.class;
    }
    result = objc_allocateClassPair(superclass, className, 0);
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
    DNBlockWrapper *wrapper = [[DNBlockWrapper alloc] initWithTypeString:types callback:(NativeBlockCallback)callback];
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

const char **
native_all_type_encodings() {
    return typeList;
}


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

const void *
native_convert_nsstring_to_utf16(NSString *string, NSUInteger *length) {
    NSData *data = [string dataUsingEncoding:NSUTF16StringEncoding];
    // UTF16, 2-byte per unit
    *length = data.length / 2;
    return data.bytes;
}

#pragma mark Dart VM API Init

Dart_Port native_callback_send_port;
intptr_t InitDartApiDL(void *data, Dart_Port port) {
    native_callback_send_port = port;
    return Dart_InitializeApiDL(data);
}

#pragma mark - Async Callback Basic

typedef std::function<void()> Work;

void NotifyDart(Dart_Port send_port, const Work* work) {
    const intptr_t work_addr = reinterpret_cast<intptr_t>(work);

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kInt64;
    dart_object.value.as_int64 = work_addr;

    const bool result = Dart_PostCObject_DL(send_port, &dart_object);
    if (!result) {
      NSLog(@"Native callback to Dart failed! Invalid port or isolate died");
    }
}

DN_EXTERN
void ExecuteCallback(Work* work_ptr) {
    const Work work = *work_ptr;
    work();
    delete work_ptr;
}

#pragma mark - Async Block Callback

void NotifyBlockInvokeToDart(DNInvocation *invocation,
                             DNBlockWrapper *wrapper,
                             int numberOfArguments) {
    BOOL blocking = strcmp(wrapper.typeEncodings[0], "v") != 0;
    dispatch_semaphore_t sema;
    if (blocking) {
        sema = dispatch_semaphore_create(0);
    }
    NativeBlockCallback callback = wrapper.callback;
    const Work work = [wrapper, numberOfArguments, callback, sema, invocation]() {
        callback(invocation.realArgs,
                 invocation.realRetValue,
                 numberOfArguments,
                 wrapper.hasStret);
        if (sema) {
            dispatch_semaphore_signal(sema);
        }
    };
    const Work* work_ptr = new Work(work);
    NotifyDart(native_callback_send_port, work_ptr);
    if (sema) {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - Async Method Callback

void NotifyMethodPerformToDart(DNInvocation *invocation,
                               DNMethodIMP *methodIMP,
                               int numberOfArguments,
                               const char **types) {
    BOOL blocking = strcmp(types[0], "v") != 0;
    dispatch_semaphore_t sema;
    if (blocking) {
        sema = dispatch_semaphore_create(0);
    }
    NativeMethodCallback callback = methodIMP.callback;
    const Work work = [invocation, methodIMP, numberOfArguments, types, callback, sema]() {
        callback(invocation.realArgs,
                 invocation.realRetValue,
                 numberOfArguments,
                 types,
                 methodIMP.stret);
        if (sema) {
            dispatch_semaphore_signal(sema);
        }
    };
    const Work* work_ptr = new Work(work);
    NotifyDart(native_callback_send_port, work_ptr);
    if (sema) {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - Native Dealloc Callback

void (*native_dealloc_callback)(intptr_t);

void RegisterDeallocCallback(void (*callback)(intptr_t)) {
    native_dealloc_callback = callback;
}

void NotifyDeallocToDart(intptr_t address) {
    auto callback = native_dealloc_callback;
    const Work work = [address, callback]() { callback(address); };
    const Work* work_ptr = new Work(work);
    NotifyDart(native_callback_send_port, work_ptr);
}

#pragma mark - Dart Finalizer

static void RunFinalizer(void *isolate_callback_data,
                         Dart_WeakPersistentHandle handle,
                         void *peer) {
    SEL selector = NSSelectorFromString(@"release");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [(__bridge id)peer performSelector:selector];
    #pragma clang diagnostic pop
}

void PassObjectToCUseDynamicLinking(Dart_Handle h, id object) {
    // Only Block handles lifetime of BlockWrapper. So we can't transfer it to Dart.
    if (Dart_IsError_DL(h) || [object isKindOfClass:DNBlockWrapper.class]) {
        return;
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object performSelector:NSSelectorFromString(@"retain")];
    #pragma clang diagnostic pop
    Dart_NewWeakPersistentHandle_DL(h, (__bridge void *)(object), 8, RunFinalizer);
}
