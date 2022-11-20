//
//  DNDartBridge.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/21.
//

#import <Foundation/Foundation.h>

#import "DNExtern.h"
#import "DNTypeEncoding.h"

@class DNBlockCreator;
@class DNMethodIMP;
@class DNInvocation;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Dart VM API

DN_EXTERN intptr_t InitDartApiDL(void *data);

#pragma mark - Async Callback Basic

DN_EXTERN BOOL TestNotifyDart(Dart_Port send_port);

#pragma mark - Async Block Callback

DN_EXTERN void NotifyBlockInvokeToDart(DNInvocation *invocation,
                                       DNBlockCreator *wrapper,
                                       int numberOfArguments);

#pragma mark - Async Method Callback

DN_EXTERN void NotifyMethodPerformToDart(DNInvocation *invocation,
                                         DNMethodIMP *methodIMP,
                                         int numberOfArguments,
                                         const char *_Nonnull *_Nonnull types);

#pragma mark - Memory Management

typedef NS_CLOSED_ENUM(NSUInteger, DNPassObjectResult) {
    DNPassObjectResultFailed,
    DNPassObjectResultSuccess,
    DNPassObjectResultNeedless,
};

/// Bind the lifetime of an Objective-C object to a dart object.
/// @param h A dart object with identity.
/// @param pointer pointer to an Objective-C object.
DN_EXTERN DNPassObjectResult BindObjcLifecycleToDart(Dart_Handle h, void *pointer);

DN_EXTERN void RegisterDartFinalizer(Dart_Handle h, void *callback, void *key, Dart_Port dartPort);

DN_EXTERN void NotifyDeallocToDart(intptr_t address, Dart_Port dartPort);

DN_EXTERN void RegisterDeallocCallback(void (*callback)(intptr_t), Dart_Port dartPort);

NS_ASSUME_NONNULL_END
