//
//  native_runtime.mm
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/24.
//

#import "native_runtime.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import <os/lock.h>
#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <functional>

#import "DNBlockHelper.h"
#import "DNBlockCreator.h"
#import "DNFFIHelper.h"
#import "DNMethodIMP.h"
#import "DNObjectDealloc.h"
#import "DNPointerWrapper.h"
#import "DNInvocation.h"
#import "NSObject+DartHandleExternalSize.h"
#import "NSNumber+DNUnwrapValues.h"
#import "DNError.h"
#import "DNException.h"
#import "DNMemoryValidation.h"
#import "NSString+DartNative.h"

static Class DNInterfaceRegistryClass = NSClassFromString(@"DNInterfaceRegistry");

#pragma mark - Objective-C runtime functions

NSMethodSignature *native_method_signature(Class cls, SEL selector) {
    if (!selector) {
        return nil;
    }
    NSMethodSignature *signature = [cls instanceMethodSignatureForSelector:selector];
    return signature;
}

void native_signature_encoding_list(NSMethodSignature *signature, const char **typeEncodings, BOOL decodeRetVal) {
    if (!signature || !typeEncodings) {
        return;
    }
    
    for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
        const char *type = [signature getArgumentTypeAtIndex:i];
        *(typeEncodings + i - 1) = native_type_encoding(type);
    }
    if (decodeRetVal) {
        *typeEncodings = native_type_encoding(signature.methodReturnType);
    }
}

BOOL native_add_method(id target, SEL selector, char *types, bool returnString, void *callback, Dart_Port dartPort) {
    Class cls = object_getClass(target);
    NSString *selName = [NSString stringWithFormat:@"dart_native_%@", NSStringFromSelector(selector)];
    SEL key = NSSelectorFromString(selName);
    DNMethodIMP *imp = objc_getAssociatedObject(cls, key);
    // Existing implemention can't be replaced. Flutter hot-reload must also be well handled.
    if ([target respondsToSelector:selector]) {
        if (imp) {
            [imp addCallback:(NativeMethodCallback)callback forDartPort:dartPort];
            return YES;
        } else {
            return NO;
        }
    }
    if (types != NULL) {
        NSError *error;
        DNMethodIMP *methodIMP = [[DNMethodIMP alloc] initWithTypeEncoding:types
                                                                  callback:(NativeMethodCallback)callback
                                                              returnString:returnString
                                                                  dartPort:dartPort
                                                                     error:&error];
        if (error.code) {
            return NO;
        }
        IMP imp = [methodIMP imp];
        if (!imp) {
            return NO;
        }
        class_replaceMethod(cls, selector, imp, types);
        // DNMethodIMP always exists.
        objc_setAssociatedObject(cls, key, methodIMP, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return YES;
    }
    return NO;
}

char *native_protocol_method_types(Protocol *proto, SEL selector) {
    struct objc_method_description description = protocol_getMethodDescription(proto, selector, YES, YES);
    if (description.types == NULL) {
        description = protocol_getMethodDescription(proto, selector, NO, YES);
    }
    return description.types;
}

Class native_get_class(const char *className, Class superclass) {
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

void *_mallocReturnStruct(NSMethodSignature *signature) {
    const char *type = signature.methodReturnType;
    NSUInteger size;
    DNSizeAndAlignment(type, &size, NULL, NULL);
    // Struct is copied on heap, it will be freed when dart side no longer owns it.
    void *result = malloc(size);
    return result;
}

void _fillArgsToInvocation(NSMethodSignature *signature, void **args, NSInvocation *invocation, NSUInteger offset, int64_t stringTypeBitmask, NSMutableArray<NSString *> *stringTypeBucket) {
    if (!args) {
        return;
    }
    for (NSUInteger i = offset; i < signature.numberOfArguments; i++) {
        const char *argType = [signature getArgumentTypeAtIndex:i];
        NSUInteger argsIndex = i - offset;
        if (argType[0] == '*') {
            // Copy CString to NSTaggedPointerString and transfer it's lifecycle to ARC. Orginal pointer will be freed after function returning.
            const char *arg = (const char *)args[argsIndex];
            if (arg) {
                const char *temp = [NSString stringWithUTF8String:arg].UTF8String;
                if (temp) {
                    args[argsIndex] = (void *)temp;
                }
            }
        }
        if (argType[0] == '{') {
            // Already put struct in pointer on Dart side.
            void *arg = args[argsIndex];
            if (arg) {
                [invocation setArgument:arg atIndex:i];
            }
        } else if (argType[0] == '@' &&
                   (stringTypeBitmask >> argsIndex & 0x1) == 1) {
            const unichar *data = ((const unichar **)args)[argsIndex];
            NSString *realArg = [NSString dn_stringWithUTF16String:data];
            [stringTypeBucket addObject:realArg];
            [invocation setArgument:&realArg atIndex:i];
        } else {
            [invocation setArgument:&args[argsIndex] atIndex:i];
        }
    }
}

void *native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, dispatch_queue_t queue, void **args, void (^callback)(void *), Dart_Port dartPort, int64_t stringTypeBitmask, const char **retType) {
    if (!object || !selector || !signature) {
        return NULL;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = object;
    invocation.selector = selector;
    NSMutableArray<NSString *> *stringTypeBucket = [NSMutableArray array];
    _fillArgsToInvocation(signature, args, invocation, 2, stringTypeBitmask, stringTypeBucket);
    
    void *(^resultBlock)() = ^() {
        void *result = NULL;
        const char returnType = signature.methodReturnType[0];
        if (signature.methodReturnLength > 0) {
            if (returnType == '{') {
                result = _mallocReturnStruct(signature);
                [invocation getReturnValue:result];
            } else {
                [invocation getReturnValue:&result];
                if (returnType == '@') {
                    BOOL isNSString = [(__bridge id)result isKindOfClass:NSString.class];
                    // highest bit is a flag for decode.
                    BOOL decodeRetVal = (stringTypeBitmask & (1LL << 63)) != 0;
                    // return value will be passed into callback block.
                    BOOL returnUsingCallback = queue && callback;
                    // return value is a NSString and needs decode.
                    if (isNSString && decodeRetVal && !returnUsingCallback) {
                        // change return type from 'object' to 'string'.
                        if (retType) {
                            *retType = native_type_string;
                        }
                        result = (void *)[(__bridge NSString *)result dn_UTF16Data];
                    } else {
                        [DNObjectDealloc attachHost:(__bridge id)result
                                           dartPort:dartPort];
                    }
                }
            }
        }
        return result;
    };
    
    if (queue) {
        // Retain arguments and return nil immediately.
        [invocation retainArguments];
        dispatch_async(queue, ^{
            [invocation invoke];
            if (callback) {
                void *result = resultBlock();
                callback(result);
            }
        });
        return nil;;
    } else {
        [invocation invoke];
        return resultBlock();
    }
}

void *native_block_create(char *types, void *function, BOOL shouldReturnAsync, Dart_Port dartPort) {
    NSError *error;
    DNBlockCreator *creator = [[DNBlockCreator alloc] initWithTypeString:types
                                                                function:(BlockFunctionPointer)function
                                                             returnAsync:shouldReturnAsync
                                                                dartPort:dartPort
                                                                   error:&error];
    if (error.code) {
        return nil;
    }
    id block = [creator blockWithError:&error];
    if (error.code) {
        return nil;
    }
    return (__bridge void *)block;
}

void *native_block_invoke(void *block, void **args, Dart_Port dartPort, int64_t stringTypeBitmask, const char **retType) {
    if (!block) {
        return nullptr;
    }
    const char *typeString = DNBlockTypeEncodeString((__bridge id)block);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSMutableArray<NSString *> *stringTypeBucket = [NSMutableArray array];
    _fillArgsToInvocation(signature, args, invocation, 1, stringTypeBitmask, stringTypeBucket);
    [invocation invokeWithTarget:(__bridge id)block];
    void *result = NULL;
    const char returnType = signature.methodReturnType[0];
    if (signature.methodReturnLength > 0) {
        if (returnType == '{') {
            result = _mallocReturnStruct(signature);
            [invocation getReturnValue:result];
        } else {
            [invocation getReturnValue:&result];
            BOOL isNSString = [(__bridge id)result isKindOfClass:NSString.class];
            BOOL decodeRetVal = (stringTypeBitmask & (1LL << 63)) != 0;
            // return value is a NSString and needs decode.
            if (isNSString && decodeRetVal) {
                // change return type from 'object' to 'string'.
                if (retType) {
                    *retType = native_type_string;
                }
                result = (void *)[(__bridge NSString *)result dn_UTF16Data];
            } else {
                [DNObjectDealloc attachHost:(__bridge id)result
                                   dartPort:dartPort];
            }
        }
    }
    return result;
}

// Use pointer as key of encoding string cache (on dart side).
#define DEF_NATIVE_TYPE(name) const char *native_type_##name = #name;
DEF_NATIVE_TYPE(sint8)
DEF_NATIVE_TYPE(sint16)
DEF_NATIVE_TYPE(sint32)
DEF_NATIVE_TYPE(sint64)
DEF_NATIVE_TYPE(uint8)
DEF_NATIVE_TYPE(uint16)
DEF_NATIVE_TYPE(uint32)
DEF_NATIVE_TYPE(uint64)
DEF_NATIVE_TYPE(float32)
DEF_NATIVE_TYPE(float64)
DEF_NATIVE_TYPE(object)
DEF_NATIVE_TYPE(class)
DEF_NATIVE_TYPE(selector)
DEF_NATIVE_TYPE(block)
DEF_NATIVE_TYPE(char_ptr)
DEF_NATIVE_TYPE(void)
DEF_NATIVE_TYPE(ptr)
DEF_NATIVE_TYPE(bool)
DEF_NATIVE_TYPE(string)

static const char *typeList[] = {
    native_type_sint8,
    native_type_sint16,
    native_type_sint32,
    native_type_sint64,
    native_type_uint8,
    native_type_uint16,
    native_type_uint32,
    native_type_uint64,
    native_type_float32,
    native_type_float64,
    native_type_object,
    native_type_class,
    native_type_selector,
    native_type_block,
    native_type_char_ptr,
    native_type_void,
    native_type_ptr,
    native_type_bool,
    native_type_string
};

const char **
native_all_type_encodings() {
    return typeList;
}

#define SINT(type) do { \
    if (str[0] == @encode(type)[0]) { \
        size_t size = sizeof(type); \
        if (size == 1) { \
            return native_type_sint8; \
        } else if (size == 2) { \
            return native_type_sint16; \
        } else if (size == 4) { \
            return native_type_sint32; \
        } else if (size == 8) { \
            return native_type_sint64; \
        } else { \
            NSLog(@"Unknown size for type %s", #type); \
            abort(); \
        } \
    } \
} while(0)

#define UINT(type) do { \
    if (str[0] == @encode(type)[0]) { \
        size_t size = sizeof(type); \
        if (size == 1) { \
            return native_type_uint8; \
        } else if (size == 2) { \
            return native_type_uint16; \
        } else if (size == 4) { \
            return native_type_uint32; \
        } else if (size == 8) { \
            return native_type_uint64; \
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
    if (str[0] == @encode(type)[0]) {\
        return name; \
    } \
} while(0)

#define PTR(type) COND(type, native_type_ptr)

// When returns struct encoding, it needs to be freed.
const char *native_type_encoding(const char *str) {
    if (!str || strlen(str) == 0) {
        return NULL;
    }
    
    COND(_Bool, native_type_bool);
    SINT(signed char);
    UINT(unsigned char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    COND(float, native_type_float32);
    COND(double, native_type_float64);
    
    if (strcmp(str, "@?") == 0) {
        return native_type_block;
    }
    
    COND(id, native_type_object);
    COND(Class, native_type_class);
    COND(SEL, native_type_selector);
    PTR(void *);
    COND(char *, native_type_char_ptr);
    COND(void, native_type_void);
    
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

// Returns type encodings whose need to be freed.
const char **native_types_encoding(const char *str, int *count, int startIndex) {
    int argCount = DNTypeCount(str) - startIndex;
    if (argCount <= 0) {
        return nil;
    }
    const char **argTypes = (const char **)malloc(sizeof(char *) * argCount);
    if (argTypes == NULL) {
        return argTypes;
    }
    
    int i = -startIndex;
    if (!str || !*str) {
        free(argTypes);
        return nil;
    }
    while (str && *str) {
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

// Returns struct encoding which will be freed.
const char *native_struct_encoding(const char *encoding) {
    NSUInteger size, align;
    long length;
    DNSizeAndAlignment(encoding, &size, &align, &length);
    NSString *str = [NSString stringWithUTF8String:encoding];
    const char *temp = [str substringWithRange:NSMakeRange(0, length)].UTF8String;
    if (!temp) {
        return nil;
    }
    int structNameLength = 0;
    // cut "struct="
    while (*temp && *temp != '=') {
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
        const char *element = elements[i];
        [structType appendFormat:@"%@", [NSString stringWithUTF8String:element]];
        // `structType` contains other structs, we should free nested struct types.
        if (*element == '{') {
            free((void *)element);
        }
    }
    [structType appendString:@"}"];
    free(elements);
    // Malloc struct type, it will be freed on dart side.
    const char *encodeSource = structType.UTF8String;
    size_t typeLength = strlen(encodeSource) + 1;
    char *typePtr = (char *)malloc(sizeof(char) * typeLength);
    strlcpy(typePtr, encodeSource, typeLength);
    return typePtr;
}

bool LP64() {
#if defined(__LP64__) && __LP64__
    return true;
#else
    return false;
#endif
}

bool NS_BUILD_32_LIKE_64() {
#if defined(NS_BUILD_32_LIKE_64) && NS_BUILD_32_LIKE_64
    return true;
#else
    return false;
#endif
}

dispatch_queue_main_t _dispatch_get_main_queue(void) {
    return dispatch_get_main_queue();
}

void native_retain_object(id object) {
    SEL selector = NSSelectorFromString(@"retain");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object performSelector:selector];
    #pragma clang diagnostic pop
}

void native_release_object(id object) {
    SEL selector = NSSelectorFromString(@"release");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object performSelector:selector];
    #pragma clang diagnostic pop
}

void native_autorelease_object(id object) {
    SEL selector = NSSelectorFromString(@"autorelease");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object performSelector:selector];
    #pragma clang diagnostic pop
}

#pragma mark Dart VM API Init

intptr_t InitDartApiDL(void *data) {
    return Dart_InitializeApiDL(data);
}

#pragma mark - Async Callback Basic

typedef std::function<void()> Work;

BOOL NotifyDart(Dart_Port send_port, const Work *work) {
    const intptr_t work_addr = reinterpret_cast<intptr_t>(work);
    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kInt64;
    dart_object.value.as_int64 = work_addr;

    const bool result = Dart_PostCObject_DL(send_port, &dart_object);
    if (!result) {
        NSLog(@"Native callback to Dart failed! Invalid port or isolate died");
    }
    return result;
}

BOOL TestNotifyDart(Dart_Port send_port) {
    return NotifyDart(send_port, nullptr);
}

DN_EXTERN
void ExecuteCallback(Work *work_ptr) {
    const Work work = *work_ptr;
    work();
    delete work_ptr;
}

#pragma mark - Async Block Callback

static NSString * const DNBlockingUIExceptionReason = @"Calling dart function from main thread will blocking the UI";
static NSExceptionName const DNBlockingUIException = @"BlockingUIException";

void NotifyBlockInvokeToDart(DNInvocation *invocation,
                             DNBlockCreator *creator,
                             int numberOfArguments) {
    if (NSThread.isMainThread && DartNativeCanThrowException()) {
        @throw [NSException exceptionWithName:DNBlockingUIException
                                       reason:DNBlockingUIExceptionReason
                                     userInfo:nil];
    }
    BOOL isVoid = invocation.methodSignature.methodReturnType[0] == 'v';
    BOOL shouldReturnAsync = creator.shouldReturnAsync;
    dispatch_semaphore_t sema;
    if (!isVoid || !shouldReturnAsync) {
        sema = dispatch_semaphore_create(0);
    }
    
    BlockFunctionPointer function = creator.function;
    const Work work = [function, numberOfArguments, isVoid, shouldReturnAsync, &sema, creator, invocation]() {
        function(invocation.realArgs,
                 invocation.realRetValue,
                 numberOfArguments,
                 creator.hasStret,
                 creator.sequence);
        if (!isVoid || !shouldReturnAsync) {
            dispatch_semaphore_signal(sema);
        }
    };
    const Work *work_ptr = new Work(work);
    BOOL success = NotifyDart(creator.dartPort, work_ptr);
    if (success && (!isVoid || !shouldReturnAsync)) {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - Async Method Callback

void NotifyMethodPerformToDart(DNInvocation *invocation,
                               DNMethodIMP *methodIMP,
                               int numberOfArguments,
                               const char **types) {
    if (NSThread.isMainThread && DartNativeCanThrowException()) {
        @throw [NSException exceptionWithName:DNBlockingUIException
                                       reason:DNBlockingUIExceptionReason
                                     userInfo:nil];
    }
    dispatch_group_t group = dispatch_group_create();
    NSDictionary<NSNumber *, NSNumber *> *callbackForDartPort = methodIMP.callbackForDartPort;
    // Each isolate has a ReceivePort for callbacks.
    // `invocation.args[0]` is delegate object, whose dealloc object records it's dart ports.
    DNObjectDealloc *dealloc = [DNObjectDealloc objectForHost:(__bridge id)(*(void **)invocation.args[0])];
    NSSet<NSNumber *> *dartPorts = dealloc.dartPorts;
    for (NSNumber *port in dartPorts) {
        NativeMethodCallback callback = (NativeMethodCallback)callbackForDartPort[port].integerValue;
        const Work work = [callback, numberOfArguments, types, &group, methodIMP, invocation]() {
            callback(invocation.realArgs,
                     invocation.realRetValue,
                     numberOfArguments,
                     types,
                     methodIMP.stret);
            dispatch_group_leave(group);
        };
        const Work *work_ptr = new Work(work);
        Dart_Port dartPort = port.integerValue;
        BOOL success = NotifyDart(dartPort, work_ptr);
        if (success) {
            dispatch_group_enter(group);
        } else {
            // Remove port in died isolate
            [methodIMP removeCallbackForDartPort:dartPort];
        }
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

#pragma mark - Native Dealloc Callback

static NSMutableDictionary<NSNumber *, NSNumber *> *deallocCallbackPtrForDartPort = [NSMutableDictionary dictionary];
static dispatch_queue_t deallocCallbackPortsQueue = dispatch_queue_create("com.dartnative.deallocCallback", DISPATCH_QUEUE_CONCURRENT);;

void RegisterDeallocCallback(void (*callback)(intptr_t), Dart_Port dartPort) {
    dispatch_barrier_async(deallocCallbackPortsQueue, ^{
        deallocCallbackPtrForDartPort[@(dartPort)] = @((intptr_t)callback);
    });
}

void NotifyDeallocToDart(intptr_t address, Dart_Port dartPort) {
    dispatch_async(deallocCallbackPortsQueue, ^{
        void (*callback)(intptr_t) = reinterpret_cast<void (*)(intptr_t)>(deallocCallbackPtrForDartPort[@(dartPort)].longValue);
        if (callback) {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                const Work work = [address, callback]() {
                    callback(address);
                };
                const Work *work_ptr = new Work(work);
                bool success = NotifyDart(dartPort, work_ptr);
                if (!success) {
                    dispatch_barrier_async(deallocCallbackPortsQueue, ^{
                        deallocCallbackPtrForDartPort[@(dartPort)] = nil;
                    });
                }
            });
        }
    });
}

#pragma mark - Dart Finalizer

static NSMutableDictionary<NSNumber *, NSNumber *> *objectRefCount = [NSMutableDictionary dictionary];

API_AVAILABLE(ios(10.0), macos(10.12))
static os_unfair_lock _refCountUnfairLock = OS_UNFAIR_LOCK_INIT;
static NSRecursiveLock *_refCountLock = [[NSRecursiveLock alloc] init];

static void _RunFinalizer(void *isolate_callback_data,
                         void *peer) {
    NSNumber *address = @((intptr_t)peer);
    NSUInteger refCount = objectRefCount[address].unsignedIntegerValue;
    if (refCount > 1) {
        objectRefCount[address] = @(refCount - 1);
        return;
    }
    native_release_object((__bridge id)peer);
    objectRefCount[address] = nil;
}

/// RunFinalizer is a function that will be invoked sometime after the object is garbage collected, unless the handle has been deleted. It can be called by _BindObjcLifecycleToDart. See Dart_HandleFinalizer.
static void RunFinalizer(void *isolate_callback_data,
                         void *peer) {
    if (@available(iOS 10.0, macOS 10.12, *)) {
        bool success = os_unfair_lock_trylock(&_refCountUnfairLock);
        _RunFinalizer(isolate_callback_data, peer);
        if (success) {
            os_unfair_lock_unlock(&_refCountUnfairLock);
        }
    } else {
        [_refCountLock lock];
        _RunFinalizer(isolate_callback_data, peer);
        [_refCountLock unlock];
    }
}

DNPassObjectResult _BindObjcLifecycleToDart(Dart_Handle h, void *pointer) {
    NSNumber *address = @((intptr_t)pointer);
    NSUInteger refCount = objectRefCount[address].unsignedIntegerValue;
    // pointer is already retained by dart object, just increase its reference count.
    if (refCount > 0) {
        id object = (__bridge id)pointer;
        size_t size = [object dn_objectSize];
        Dart_NewWeakPersistentHandle_DL(h, pointer, size, RunFinalizer);
        objectRefCount[address] = @(refCount + 1);
        return DNPassObjectResultSuccess;
    }
    // First invoking on pointer. Slow path.
    bool isValid = native_isValidPointer(pointer);
    if (!isValid) {
        return DNPassObjectResultFailed;
    }
    
    id object = (__bridge id)pointer;
    if (object_isClass(object)) {
        return DNPassObjectResultFailed;
    }
    // DartVM Error.
    if (Dart_IsError_DL(h)) {
        return DNPassObjectResultFailed;
    }
    // Only Block handles lifetime of DNBlockHelper. So we can't transfer it to Dart.
    if ([object isKindOfClass:DNBlockHelper.class]) {
        return DNPassObjectResultNeedless;
    }
    native_retain_object(object);
    size_t size = [object dn_objectSize];
    Dart_NewWeakPersistentHandle_DL(h, pointer, size, RunFinalizer);
    objectRefCount[address] = @1;
    return DNPassObjectResultSuccess;
}

DNPassObjectResult BindObjcLifecycleToDart(Dart_Handle h, void *pointer) {
    DNPassObjectResult result;
    if (@available(iOS 10.0, macOS 10.12, *)) {
        os_unfair_lock_lock(&_refCountUnfairLock);
        result = _BindObjcLifecycleToDart(h, pointer);
        os_unfair_lock_unlock(&_refCountUnfairLock);
    } else {
        [_refCountLock lock];
        result = _BindObjcLifecycleToDart(h, pointer);
        [_refCountLock unlock];
    }
    return result;
}

typedef struct Finalizer {
    void *callback;
    void *key;
    Dart_Port dartPort;
} Finalizer;

static void RunDartFinalizer(void *isolate_callback_data, void *peer) {
    Finalizer *finalizer = (Finalizer *)peer;
    void (*callback)(void *) = (void(*)(void *))finalizer->callback;
    void *key = finalizer->key;
    const Work work = [callback, key]() {
        callback(key);
    };
    const Work *work_ptr = new Work(work);
    BOOL success = NotifyDart(finalizer->dartPort, work_ptr);
    if (success) {
        free(finalizer);
    }
}

void RegisterDartFinalizer(Dart_Handle h, void *callback, void *key, Dart_Port dartPort) {
    Finalizer *finalizer = new Finalizer({callback, key, dartPort});
    Dart_NewWeakPersistentHandle_DL(h, finalizer, 8, RunDartFinalizer);
}

#pragma mark - Interface

/// Each interface has an object on each thread. Cuz the DartNative.framework doesn't contain DNInterfaceRegistry class, so we have to use objc runtime.
/// @param name name of interface
NSObject *DNInterfaceHostObjectWithName(char *name) {
    Class target = DNInterfaceRegistryClass;
    SEL selector = NSSelectorFromString(@"hostObjectWithName:");
    if (!target || !selector) {
        if (DartNativeCanThrowException()) {
            @throw [NSException exceptionWithName:DNClassNotFoundException
                                           reason:DNClassNotFoundExceptionReason
                                         userInfo:nil];
        }
        return nil;
    }
    NSString *nameString = [NSString stringWithUTF8String:name];
    return ((NSObject *(*)(Class, SEL, NSString *))objc_msgSend)(target, selector, nameString);
}

DartNativeInterfaceMap DNInterfaceAllMetaData(void) {
    Class target = DNInterfaceRegistryClass;
    SEL selector = NSSelectorFromString(@"allMetaData");
    if (!target || !selector) {
        if (DartNativeCanThrowException()) {
            @throw [NSException exceptionWithName:DNClassNotFoundException
                                           reason:DNClassNotFoundExceptionReason
                                         userInfo:nil];
        }
        return nil;
    }
    return ((DartNativeInterfaceMap(*)(Class, SEL))objc_msgSend)(target, selector);
}

void DNInterfaceRegisterDartInterface(char *interface, char *method, id block, Dart_Port port) {
    Class target = DNInterfaceRegistryClass;
    SEL selector = NSSelectorFromString(@"registerDartInterface:method:block:dartPort:");
    if (!target || !selector) {
        if (DartNativeCanThrowException()) {
            @throw [NSException exceptionWithName:DNClassNotFoundException
                                           reason:DNClassNotFoundExceptionReason
                                         userInfo:nil];
        }
        return;
    }
    NSString *interfaceString = [NSString stringWithUTF8String:interface];
    NSString *methodString = [NSString stringWithUTF8String:method];
    ((void(*)(Class, SEL, NSString *, NSString *, NSString *, int64_t))objc_msgSend)(target, selector, interfaceString, methodString, block, port);
}

void DNInterfaceBlockInvoke(void *block, NSArray *arguments, BlockResultCallback resultCallback) {
    const char *typeString = DNBlockTypeEncodeString((__bridge id)block);
    int count = 0;
    NSError *error = nil;
    const char **types = native_types_encoding(typeString, &count, 0);
    if (!types) {
        DN_ERROR(&error, DNInterfaceError, @"Parse typeString failed: %s", typeString)
        if (resultCallback) {
            resultCallback(nil, error);
        }
        return;
    }
    DNBlock *blockLayout = (DNBlock *)block;
    DNBlockCreator *creator = (__bridge DNBlockCreator *)blockLayout->creator;
    // When block returns result asynchronously, the last argument of block is the callback.
    // types/values list in block: [returnValue, block(self), arguments...(optional), callback(optional)]
    NSUInteger diff = creator.shouldReturnAsync ? 3 : 2;
    do {
        if (count != arguments.count + diff) {
            DN_ERROR(&error, DNInterfaceError, @"The number of arguments for methods dart and objc does not match!")
            if (resultCallback) {
                resultCallback(nil, error);
            }
            break;
        }
        
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeString];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        NSUInteger realArgsCount = arguments.count;
        if (creator.shouldReturnAsync) {
            realArgsCount++;
        }
        void **argsPtrPtr = (void **)alloca(realArgsCount * sizeof(void *));
        for (int i = 0; i < arguments.count; i++) {
            const char *type = types[i + 2];
            id arg = arguments[i];
            if (type == native_type_object) {
                argsPtrPtr[i] = (__bridge void *)arguments[i];
            } else if (type[0] == '{') {
                // Ignore, not support yet.
                free((void *)type);
                DN_ERROR(&error, DNInterfaceError, @"Structure types are not supported")
                if (resultCallback) {
                    resultCallback(nil, error);
                }
                break;
            } else if ([arg isKindOfClass:NSNumber.class]) {
                NSNumber *number = (NSNumber *)arg;
                // first argument is block itself, skip it.
                const char *encoding = [signature getArgumentTypeAtIndex:i + 1];
                BOOL success = [number dn_fillBuffer:argsPtrPtr + i encoding:encoding error:&error];
                if (!success) {
                    DN_ERROR(&error, DNInterfaceError, @"NSNumber convertion failed")
                    if (resultCallback) {
                        resultCallback(nil, error);
                    }
                    break;
                }
            }
        }
        // block receives results from dart function asynchronously by appending another block to arguments as its callback.
        if (creator.shouldReturnAsync) {
            // dartBlock is passed to dart, ignore `error`.
            void(^dartBlock)(id result) = ^(id result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultCallback(result, nil);
                });
            };
            // `dartBlock` will release when invocation dead.
            // So we should copy(retain) it and release after it's invoked on dart side.
            argsPtrPtr[realArgsCount - 1] = Block_copy((__bridge void *)dartBlock);
        }
        _fillArgsToInvocation(signature, argsPtrPtr, invocation, 1, 0, nil);
        [invocation invokeWithTarget:(__bridge id)block];
        if (resultCallback && !creator.shouldReturnAsync) {
            if (signature.methodReturnLength == 0) {
                DN_ERROR(&error, DNInterfaceError, @"signature.methodReturnLength of block is zero")
                resultCallback(nil, error);
                break;
            }
            void *result = NULL;
            const char *returnType = signature.methodReturnType;
            if (*returnType == '{') {
                DN_ERROR(&error, DNInterfaceError, @"Structure types are not supported")
                resultCallback(nil, error);
                break;
            }
            if (*returnType == '@') {
                [invocation getReturnValue:&result];
                resultCallback((__bridge id)result, nil);
            } else {
                [invocation getReturnValue:&result];
                // NSNumber
                NSNumber *number = [NSNumber dn_numberWithBuffer:result encoding:returnType error:&error];
                resultCallback(number, error);
            }
        }
    } while (0);
    free(types);
}
