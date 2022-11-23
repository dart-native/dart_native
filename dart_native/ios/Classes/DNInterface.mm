//
//  DNInterface.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/21.
//

#import "DNInterface.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import "DNError.h"
#import "DNException.h"
#import "DNBlockCreator.h"
#import "NSNumber+DNUnwrapValues.h"
#import "DNObjCRuntime.h"

#if !__has_feature(objc_arc)
#error
#endif

#pragma mark - Interface

/// Each interface has an object on each thread. Cuz the DartNative.framework doesn't contain DNInterfaceRegistry class, so we have to use objc runtime.
/// @param name name of interface
NSObject *DNInterfaceHostObjectWithName(char *name) {
    static Class targetClass = objc_getClass("DNInterfaceRegistry");
    static SEL selector = NSSelectorFromString(@"hostObjectWithName:");
    if (!targetClass || !selector) {
        if (DartNativeCanThrowException()) {
            @throw [NSException exceptionWithName:DNClassNotFoundException
                                           reason:DNClassNotFoundExceptionReason
                                         userInfo:nil];
        }
        return nil;
    }
    NSString *nameString = [NSString stringWithUTF8String:name];
    return ((NSObject *(*)(Class, SEL, NSString *))objc_msgSend)(targetClass, selector, nameString);
}

DartNativeInterfaceMap DNInterfaceAllMetaData(void) {
    static Class targetClass = objc_getClass("DNInterfaceRegistry");
    static SEL selector = NSSelectorFromString(@"allMetaData");
    if (!targetClass || !selector) {
        if (DartNativeCanThrowException()) {
            @throw [NSException exceptionWithName:DNClassNotFoundException
                                           reason:DNClassNotFoundExceptionReason
                                         userInfo:nil];
        }
        return nil;
    }
    return ((DartNativeInterfaceMap(*)(Class, SEL))objc_msgSend)(targetClass, selector);
}

void DNInterfaceRegisterDartInterface(char *interface, char *method, id block, Dart_Port port) {
    static Class targetClass = objc_getClass("DNInterfaceRegistry");
    static SEL selector = NSSelectorFromString(@"registerDartInterface:method:block:dartPort:");
    if (!targetClass || !selector) {
        if (DartNativeCanThrowException()) {
            @throw [NSException exceptionWithName:DNClassNotFoundException
                                           reason:DNClassNotFoundExceptionReason
                                         userInfo:nil];
        }
        return;
    }
    NSString *interfaceString = [NSString stringWithUTF8String:interface];
    NSString *methodString = [NSString stringWithUTF8String:method];
    ((void(*)(Class, SEL, NSString *, NSString *, NSString *, int64_t))objc_msgSend)(targetClass, selector, interfaceString, methodString, block, port);
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
