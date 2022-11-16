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
#import "DNObjCRuntime.h"

static Class DNInterfaceRegistryClass = NSClassFromString(@"DNInterfaceRegistry");

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
        fillArgsToInvocation(signature, argsPtrPtr, invocation, 1, 0, nil);
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
