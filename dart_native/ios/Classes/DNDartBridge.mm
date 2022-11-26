//
//  DNDartBridge.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/21.
//

#import "DNDartBridge.h"

#import <objc/runtime.h>
#include <functional>
#include <stdlib.h>
#import <os/lock.h>

#import "dart_api_dl.h"
#import "DNException.h"
#import "DNInvocation.h"
#import "DNBlockCreator.h"
#import "DNBlockHelper.h"
#import "DNMethod.h"
#import "DNObjectDealloc.h"
#import "NSObject+DartHandleExternalSize.h"
#import "DNMemoryValidation.h"
#import "DNObjCRuntime.h"

#if !__has_feature(objc_arc)
#error
#endif

#pragma mark Dart VM API Init

intptr_t InitDartApiDL(void *data) {
    return Dart_InitializeApiDL(data);
}

/// MARK: Async Callback Basic

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

/// MARK: Async Block Callback

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

/// MARK: Async Method Callback

void NotifyMethodPerformToDart(DNInvocation *invocation,
                               DNMethod *method,
                               int numberOfArguments,
                               const char **types) {
    if (NSThread.isMainThread && DartNativeCanThrowException()) {
        @throw [NSException exceptionWithName:DNBlockingUIException
                                       reason:DNBlockingUIExceptionReason
                                     userInfo:nil];
    }
    dispatch_group_t group = dispatch_group_create();
    NSDictionary<NSNumber *, NSNumber *> *callbackForDartPort = method.callbackForDartPort;
    // Each isolate has a ReceivePort for callbacks.
    // `invocation.args[0]` is delegate object, whose dealloc object records it's dart ports.
    DNObjectDealloc *dealloc = [DNObjectDealloc objectForHost:(__bridge id)(*(void **)invocation.args[0])];
    NSSet<NSNumber *> *dartPorts = dealloc.dartPorts;
    for (NSNumber *port in dartPorts) {
        DartImplemetion imp = (DartImplemetion)callbackForDartPort[port].integerValue;
        const Work work = [imp, numberOfArguments, types, &group, method, invocation]() {
            imp(invocation.realArgs,
                     invocation.realRetValue,
                     numberOfArguments,
                     types,
                     method.stret);
            dispatch_group_leave(group);
        };
        const Work *work_ptr = new Work(work);
        Dart_Port dartPort = port.integerValue;
        BOOL success = NotifyDart(dartPort, work_ptr);
        if (success) {
            dispatch_group_enter(group);
        } else {
            // Remove port in died isolate
            [method removeDartImplemetionForPort:dartPort];
        }
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

/// MARK: Native Dealloc Callback

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

/// MARK: Dart Finalizer

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

/// @function RunFinalizer
/// @abstract RunFinalizer is a function that will be invoked sometime after the object is garbage collected,
/// unless the handle has been deleted. It can be called by _BindObjcLifecycleToDart.
///
/// @see Dart_HandleFinalizer.
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
