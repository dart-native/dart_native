//
//  native_runtime.mm
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/24.
//

#import "native_runtime.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <mach/mach.h>
#import <os/lock.h>
#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <functional>

#import "DNBlockWrapper.h"
#import "DNFFIHelper.h"
#import "DNMethodIMP.h"
#import "DNObjectDealloc.h"
#import "DNPointerWrapper.h"
#import "DNInvocation.h"
#import "NSObject+DartHandleExternalSize.h"
#import "NSNumber+DNUnwrapValues.h"

#if !__has_feature(objc_arc)
#error
#endif

#if TARGET_OS_OSX && __x86_64__
    // 64-bit Mac - tag bit is LSB
#   define OBJC_MSB_TAGGED_POINTERS 0
#else
    // Everything else - tag bit is MSB
#   define OBJC_MSB_TAGGED_POINTERS 1
#endif

#if OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1ULL<<63)
#else
#   define _OBJC_TAG_MASK 1UL
#endif

#pragma mark - Config

static bool _canThrowException = false;

void DartNativeSetThrowException(bool canThrow) {
    _canThrowException = canThrow;
}

bool DartNativeCanThrowException() {
    return _canThrowException;
}

#pragma mark - Readable and valid memory

/// Returens true if a pointer is a tagged pointer
/// @param ptr is the pointer to check
bool objc_isTaggedPointer(const void *ptr) {
    return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}

/// Returns true if the pointer points to readable and valid memory.
/// @param pointer is the pointer to check
bool native_isValidReadableMemory(const void *pointer) {
    // Check for read permissions
    vm_address_t address = (vm_address_t)pointer;
    vm_size_t vmsize = 0;
    mach_port_t object = 0;
#if defined(__LP64__) && __LP64__
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t infoCnt = VM_REGION_BASIC_INFO_COUNT_64;
    kern_return_t ret = vm_region_64(mach_task_self(), &address, &vmsize, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &infoCnt, &object);
#else
    vm_region_basic_info_data_t info;
    mach_msg_type_number_t infoCnt = VM_REGION_BASIC_INFO_COUNT;
    kern_return_t ret = vm_region(mach_task_self(), &address, &vmsize, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &infoCnt, &object);
#endif
    // vm_region/vm_region_64 returned an error or no read permission
    if (ret != KERN_SUCCESS || (info.protection&VM_PROT_READ) == 0) {
        return false;
    }
    
    // Read the memory
    vm_offset_t data = 0;
    mach_msg_type_number_t dataCnt = 0;
    ret = vm_read(mach_task_self(), (vm_address_t)pointer, sizeof(uintptr_t), &data, &dataCnt);
    if (ret != KERN_SUCCESS) {
        // vm_read returned an error
        return false;
    }
    return true;
}

/// Returns true if a pointer is valid
/// @param pointer is the pointer to check
bool native_isValidPointer(const void *pointer) {
    if (pointer == nullptr) {
        return false;
    }
    // Check for tagged pointers
    if (objc_isTaggedPointer(pointer)) {
        return true;
    }
    // Check if the pointer is aligned
    if (((uintptr_t)pointer % sizeof(uintptr_t)) != 0) {
        return false;
    }
    // Check if the pointer is not larger than VM_MAX_ADDRESS
    if ((uintptr_t)pointer > MACH_VM_MAX_ADDRESS) {
        return false;
    }
    // Check if the memory is valid and readable
    if (!native_isValidReadableMemory(pointer)) {
        return false;
    }
    return true;
}

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
        class_replaceMethod(cls, selector, [methodIMP imp], types);
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

NSString *NSStringFromUTF16Data(const unichar *data) {
    if (!data) {
        return nil;
    }
    // First four uint16_t is for data length.
    const NSUInteger lengthDataSize = 4;
    uint64_t length = data[0];
    for (int i = 1; i < lengthDataSize; i++) {
        length <<= 16;
        length |= data[i];
    }
    NSString *result = [NSString stringWithCharacters:data + lengthDataSize length:(NSUInteger)length];
    return result;
}

/// Return data for NSString: [--dataLength(64bit--)][--dataContent(utf16 without BOM)--]
/// @param retVal origin return value
uint16_t *UTF16DataFromNSString(NSString *retVal) {
    uint64_t length = 0;
    const uint16_t *utf16BufferPtr = native_convert_nsstring_to_utf16(retVal, &length);
    size_t size = sizeof(uint16_t) * (size_t)length;
    const size_t lengthDataSize = 4;
    // free memory on dart side.
    uint16_t *dataPtr = (uint16_t *)malloc(size + sizeof(uint16_t) * lengthDataSize);
    memcpy(dataPtr + lengthDataSize, utf16BufferPtr, size);
    uint16_t lengthData[4] = {
        static_cast<uint16_t>(length >> 48 & 0xffff),
        static_cast<uint16_t>(length >> 32 & 0xffff),
        static_cast<uint16_t>(length >> 16 & 0xffff),
        static_cast<uint16_t>(length & 0xffff)
    };
    memcpy(dataPtr, lengthData, sizeof(uint16_t) * lengthDataSize);
    return dataPtr;
}

void _fillArgsToInvocation(NSMethodSignature *signature, void **args, NSInvocation *invocation, NSUInteger offset, int64_t stringTypeBitmask, NSMutableArray<NSString *> *stringTypeBucket) {
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
        } else if (argType[0] == '@' &&
                   (stringTypeBitmask >> argsIndex & 0x1) == 1) {
            const unichar *data = ((const unichar **)args)[argsIndex];
            NSString *realArg = NSStringFromUTF16Data(data);
            [stringTypeBucket addObject:realArg];
            free((void *)data); // Malloc data on dart side, need free here.
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
                        result = UTF16DataFromNSString((__bridge NSString *)result);
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
    DNBlockWrapper *wrapper = [[DNBlockWrapper alloc] initWithTypeString:types
                                                                function:(BlockFunctionPointer)function
                                                             returnAsync:shouldReturnAsync
                                                                dartPort:dartPort
                                                                   error:&error];
    if (error.code) {
        return nil;
    }
    return (__bridge void *)wrapper;
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
                result = UTF16DataFromNSString((__bridge NSString *)result);
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
    const char **argTypes = (const char **)malloc(sizeof(char *) * argCount);
    if (argTypes == NULL) {
        return argTypes;
    }
    
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

// Returns struct encoding which will be freed.
const char *native_struct_encoding(const char *encoding) {
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

const uint16_t *native_convert_nsstring_to_utf16(NSString *string, uint64_t *length) {
    NSData *data = [string dataUsingEncoding:NSUTF16StringEncoding];
    // UTF16, 2-byte per unit
    *length = data.length / 2;
    uint16_t *result = (uint16_t *)data.bytes;
    if (*result == 0xFEFF || *result == 0xFFFE) { // skip BOM
        result++;
        *length = *length - 1;
    }
    return result;
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

static NSString * const BlockingUIExceptionReason = @"Calling dart function from main thread will blocking the UI";
NSExceptionName BlockingUI = @"BlockingUIException";

void NotifyBlockInvokeToDart(DNInvocation *invocation,
                             DNBlockWrapper *wrapper,
                             int numberOfArguments) {
    if (NSThread.isMainThread && DartNativeCanThrowException()) {
        @throw [NSException exceptionWithName:BlockingUI
                                       reason:BlockingUIExceptionReason
                                     userInfo:nil];
    }
    BOOL isVoid = invocation.methodSignature.methodReturnType[0] == 'v';
    BOOL shouldReturnAsync = wrapper.shouldReturnAsync;
    dispatch_semaphore_t sema;
    if (!isVoid || !shouldReturnAsync) {
        sema = dispatch_semaphore_create(0);
    }
    
    BlockFunctionPointer function = wrapper.function;
    const Work work = [=]() {
        function(invocation.realArgs,
                 invocation.realRetValue,
                 numberOfArguments,
                 wrapper.hasStret,
                 wrapper.sequence);
        if (!isVoid || !shouldReturnAsync) {
            dispatch_semaphore_signal(sema);
        }
    };
    const Work *work_ptr = new Work(work);
    BOOL success = NotifyDart(wrapper.dartPort, work_ptr);
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
        @throw [NSException exceptionWithName:BlockingUI
                                       reason:BlockingUIExceptionReason
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
        const Work work = [=]() {
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

void (*native_dealloc_callback)(intptr_t);

void RegisterDeallocCallback(void (*callback)(intptr_t)) {
    native_dealloc_callback = callback;
}

bool NotifyDeallocToDart(intptr_t address, Dart_Port dartPort) {
    auto callback = native_dealloc_callback;
    const Work work = [address, callback]() {
        callback(address);
    };

    const Work *work_ptr = new Work(work);
    return NotifyDart(dartPort, work_ptr);
}

#pragma mark - Dart Finalizer

static NSMutableDictionary<NSNumber *, NSNumber *> *objectRefCount = [NSMutableDictionary dictionary];

API_AVAILABLE(ios(10.0), macos(10.12))
static os_unfair_lock _refCountUnfairLock = OS_UNFAIR_LOCK_INIT;
static NSLock *_refCountLock = [[NSLock alloc] init];

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

static void RunFinalizer(void *isolate_callback_data,
                         void *peer) {
    if (@available(iOS 10.0, macOS 10.12, *)) {
        os_unfair_lock_lock(&_refCountUnfairLock);
        _RunFinalizer(isolate_callback_data, peer);
        os_unfair_lock_unlock(&_refCountUnfairLock);
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
    // Only Block handles lifetime of BlockWrapper. So we can't transfer it to Dart.
    if ([object isKindOfClass:DNBlockWrapper.class]) {
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

#pragma mark - Interface

/// Each interface has an object on each thread. Cuz the DartNative.framework doesn't contain DNInterfaceRegistry class, so we have to use objc runtime.
/// @param name name of interface
NSObject *DNInterfaceHostObjectWithName(char *name) {
    Class target = NSClassFromString(@"DNInterfaceRegistry");
    SEL selector = NSSelectorFromString(@"hostObjectWithName:");
    if (!target || !selector) {
        // TODO: throw exception
        return nil;
    }
    NSString *nameString = [NSString stringWithUTF8String:name];
    return ((NSObject *(*)(Class, SEL, NSString *))objc_msgSend)(target, selector, nameString);
}

DartNativeInterfaceMap DNInterfaceAllMetaData(void) {
    Class target = NSClassFromString(@"DNInterfaceRegistry");
    SEL selector = NSSelectorFromString(@"allMetaData");
    if (!target || !selector) {
        // TODO: throw exception
        return nil;
    }
    return ((DartNativeInterfaceMap(*)(Class, SEL))objc_msgSend)(target, selector);
}

void DNInterfaceRegisterDartInterface(char *interface, char *method, id block, Dart_Port port) {
    Class target = NSClassFromString(@"DNInterfaceRegistry");
    SEL selector = NSSelectorFromString(@"registerDartInterface:method:block:dartPort:");
    if (!target || !selector) {
        // TODO: throw exception
        return;
    }
    NSString *interfaceString = [NSString stringWithUTF8String:interface];
    NSString *methodString = [NSString stringWithUTF8String:method];
    ((void(*)(Class, SEL, NSString *, NSString *, NSString *, int64_t))objc_msgSend)(target, selector, interfaceString, methodString, block, port);
}

void DNInterfaceBlockInvoke(void *block, NSArray *arguments, BlockResultCallback resultCallback) {
    const char *typeString = DNBlockTypeEncodeString((__bridge id)block);
    int count = 0;
    const char **types = native_types_encoding(typeString, &count, 0);
    NSError *error = nil;
    DNBlock *blockLayout = (DNBlock *)block;
    DNBlockWrapper *wrapper = (__bridge DNBlockWrapper *)blockLayout->wrapper;
    // When block returns result asynchronously, the last argument of block is the callback.
    // types/values list in block: [returnValue, block(self), arguments...(optional), callback(optional)]
    NSUInteger diff = wrapper.shouldReturnAsync ? 3 : 2;
    if (count != arguments.count + diff) {
        DN_ERROR(&error, DNInterfaceError, @"The number of arguments for methods dart and objc does not match!")
        if (resultCallback) {
            resultCallback(nil, error);
        }
        return;
    }
    
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger realArgsCount = arguments.count;
    if (wrapper.shouldReturnAsync) {
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
            return;
        } else if ([arg isKindOfClass:NSNumber.class]) {
            NSNumber *number = (NSNumber *)arg;
            // first argument is block itself, skip it.
            const char *encoding = [signature getArgumentTypeAtIndex:i + 1];
            BOOL success = [number dn_setAsArgumentInBuffer:argsPtrPtr + i encoding:encoding error:&error];
            if (!success) {
                DN_ERROR(&error, DNInterfaceError, @"NSNumber convertion failed")
                if (resultCallback) {
                    resultCallback(nil, error);
                }
                return;
            }
        }
    }
    // block receives results from dart function asynchronously by appending another block to arguments as its callback.
    if (wrapper.shouldReturnAsync) {
        // dartBlock is passed to dart, ignore `error`.
        void(^dartBlock)(id result) = ^(id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultCallback(result, nil);
            });
        };
        // `dartBlock` will release when invocation dead.
        // So we should retain it and release after it's invoked on dart side.
        native_retain_object(dartBlock);
        argsPtrPtr[realArgsCount - 1] = (__bridge void *)dartBlock;
    }
    _fillArgsToInvocation(signature, argsPtrPtr, invocation, 1, 0, nil);
    [invocation invokeWithTarget:(__bridge id)block];
    if (resultCallback && !wrapper.shouldReturnAsync) {
        if (signature.methodReturnLength == 0) {
            DN_ERROR(&error, DNInterfaceError, @"signature.methodReturnLength of block is zero")
            resultCallback(nil, error);
            return;
        }
        void *result = NULL;
        const char *returnType = signature.methodReturnType;
        if (*returnType == '{') {
            DN_ERROR(&error, DNInterfaceError, @"Structure types are not supported")
            resultCallback(nil, error);
            return;
        }
        if (*returnType == '@') {
            [invocation getReturnValue:&result];
            resultCallback((__bridge id)result, nil);
        } else {
            [invocation getReturnValue:&result];
            // NSNumber
            NSNumber *number = [NSNumber dn_numberWithEncoding:returnType buffer:result error:&error];
            resultCallback(number, error);
        }
    }
}
