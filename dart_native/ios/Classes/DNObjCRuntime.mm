//
//  DNObjCRuntime.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/17.
//

#import "DNObjCRuntime.h"

#import <objc/runtime.h>

#import "NSString+DartNative.h"
#import "DNBlockCreator.h"
#import "DNObjectDealloc.h"

#if !__has_feature(objc_arc)
#error
#endif

/// Returns an NSMethodSignature object which contains a description of the instance method identified by a given selector.
/// - Parameters:
///   - cls: A class that owns the method.
///   - selector: A Selector that identifies the method for which to return the implementation address.
NSMethodSignature *native_method_signature(Class cls, SEL selector) {
    if (!selector) {
        return nil;
    }
    NSMethodSignature *signature = [cls instanceMethodSignatureForSelector:selector];
    return signature;
}

/// Gets type encodings for a signature
/// - Parameters:
///   - signature: The signature.
///   - typeEncodings: Type encodings(out parameter).
///   - decodeRetVal: Whether decode the return value or not.
void native_signature_encoding_list(NSMethodSignature *signature, const char **typeEncodings, BOOL decodeRetVal) {
    if (!signature || !typeEncodings) {
        return;
    }
    
    // The first two arguments are self and cmd, which are ignored.
    // So we iterate through the signature's argument list starting with the index 2.
    // The first item of typeEncodings is the return type, followed by the list of arguments types.
    for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
        const char *type = [signature getArgumentTypeAtIndex:i];
        *(typeEncodings + i - 1) = native_type_encoding(type);
    }
    
    // Insert the return type at index 0.
    if (decodeRetVal) {
        *typeEncodings = native_type_encoding(signature.methodReturnType);
    }
}

/// Adds a method for class of an instance
/// - Parameters:
///   - instance: An Objective-C instance.
///   - selector: The selector for method.
///   - typeEncodings: Type encodings for method.
///   - returnString: Whether if a method returns a String.
///   - dartImplementation: The implementation for this method, which is a function pointer converted from a dart function by dart:ffi.
///   - dartPort: The port for dart isolate.
BOOL native_add_method(id instance, SEL selector, char *typeEncodings, bool returnString, DartImplemetion dartImplementation, Dart_Port dartPort) {
    Class cls = object_getClass(instance);
    // A method is created dynamically by adding a prefix on the original method.
    NSString *selName = [NSString stringWithFormat:@"dart_native_%@", NSStringFromSelector(selector)];
    SEL key = NSSelectorFromString(selName);
    
    // Check if the method is already created.
    if ([instance respondsToSelector:selector]) {
        DNMethod *method = objc_getAssociatedObject(cls, key);
        if (method) {
            // Add or replace the implementation of method for dart port.
            // Flutter hot-reload must also be well handled.
            [method addDartImplementation:(DartImplemetion)dartImplementation
                                  forPort:dartPort];
            return YES;
        } else {
            // Existing an Objective-C implementation with same selector,
            // so it can't be replaced. It could just be a coincidence.
            return NO;
        }
    }
    
    // Add the method
    if (typeEncodings != NULL) {
        NSError *error;
        DNMethod *method = [[DNMethod alloc] initWithTypeEncoding:typeEncodings
                                                    dartImpletion:(DartImplemetion)dartImplementation
                                                     returnString:returnString
                                                         dartPort:dartPort
                                                            error:&error];
        if (error.code) {
            return NO;
        }
        IMP imp = [method objcIMP];
        if (!imp) {
            return NO;
        }
        class_replaceMethod(cls, selector, imp, typeEncodings);
        // DNMethod always exists, save it.
        objc_setAssociatedObject(cls, key, method, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return YES;
    }
    return NO;
}

/// Finds the instance method for selector in protocol and returns its type encodings.
/// - Parameters:
///   - proto: A protocol, has to be implemented by some method.
///   - selector: The selector of method.
char *native_protocol_method_types(Protocol *proto, SEL selector) {
    struct objc_method_description description = protocol_getMethodDescription(proto, selector, YES, YES);
    if (description.types == NULL) {
        description = protocol_getMethodDescription(proto, selector, NO, YES);
    }
    return description.types;
}

/// Returns the class definition of a specified class name, or creates a new class using a superclass if it's undefined.
/// - Parameters:
///   - className: The class name.
///   - superclass: The class to use as the new class's superclass.
Class native_get_class(const char *className, Class _Nullable superclass) {
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

/// Allocate memory on heap with size of the return type.
/// - Parameter signature: A signature.
/// @Discussion To avoid memory leaks, you must free the result pointer after using it.
void *allocateBufferForReturnValue(NSMethodSignature *signature) {
    const char *type = signature.methodReturnType;
    NSUInteger size;
    DNSizeAndAlignment(type, &size, NULL, NULL);
    void *result = malloc(size);
    return result;
}

/// Fills arguments to an invocation.
/// @param signature A signature for the invocation. This argument is passed to save performance.
/// @param args The arguments list.
/// @param invocation The invocation.
/// @param offset The offset to start filling.
/// @param stringTypeBitmask A bitmask for checking if an argument is a string.
/// @param stringTypeBucket A bucket for extending the life cycle of string objects.
///
/// @Discussion Passing arguments with String types are optimized for performance.
/// Strings are encoding and decoding with UTF16.
void fillArgsToInvocation(NSMethodSignature *signature, void **args, NSInvocation *invocation, NSUInteger offset, int64_t stringTypeBitmask, NSMutableArray<NSString *> *stringTypeBucket) {
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

/// Invokes an Objective-C method from Dart.
/// @param object The instance or class object.
/// @param selector The selector of method.
/// @param signature The signature of method.
/// @param queue The dispatch queue for async method.
/// @param args Arguments passed to method.
/// @param dartPort The port for dart isolate.
/// @param stringTypeBitmask A bitmask for checking if an argument is a string.
/// @param retType Type of return value(out parameter).
void *native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, dispatch_queue_t queue, void **args, void (^callback)(void *), Dart_Port dartPort, int64_t stringTypeBitmask, const char **retType) {
    if (!object || !selector || !signature) {
        return NULL;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = object;
    invocation.selector = selector;
    NSMutableArray<NSString *> *stringTypeBucket = [NSMutableArray array];
    fillArgsToInvocation(signature, args, invocation, 2, stringTypeBitmask, stringTypeBucket);
    
    void *(^resultBlock)() = ^() {
        void *result = NULL;
        const char returnType = signature.methodReturnType[0];
        if (signature.methodReturnLength > 0) {
            if (returnType == '{') {
                // Struct is copied on heap, it should be freed when dart side no longer owns it.
                result = allocateBufferForReturnValue(signature);
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

/// Creates a block object from Dart.
/// @param types Type encodings for creating the block.
/// @param function A function of type BlockFunctionPointer, which would be called when the block is invoking.
/// @param shouldReturnAsync Whether if a block returns a Future to Dart.
/// @param dartPort The port for dart isolate.
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

/// Invokes an Objective-C block from Dart.
/// @param block The block object.
/// @param args Arguments passed to block.
/// @param dartPort The port for dart isolate.
/// @param stringTypeBitmask A bitmask for checking if an argument is a string.
/// @param retType Type of return value(out parameter).
void *native_block_invoke(void *block, void **args, Dart_Port dartPort, int64_t stringTypeBitmask, const char **retType) {
    if (!block) {
        return nullptr;
    }
    const char *typeString = DNBlockTypeEncodeString((__bridge id)block);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSMutableArray<NSString *> *stringTypeBucket = [NSMutableArray array];
    fillArgsToInvocation(signature, args, invocation, 1, stringTypeBitmask, stringTypeBucket);
    [invocation invokeWithTarget:(__bridge id)block];
    void *result = NULL;
    const char returnType = signature.methodReturnType[0];
    if (signature.methodReturnLength > 0) {
        if (returnType == '{') {
            // Struct is copied on heap, it will be freed when dart side no longer owns it.
            result = allocateBufferForReturnValue(signature);
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

/// Returns a Boolean value that indicates whether macro __LP64__ is enabled.
bool LP64() {
#if defined(__LP64__) && __LP64__
    return true;
#else
    return false;
#endif
}

/// Returns a Boolean value that indicates whether macro NS_BUILD_32_LIKE_64 is enabled.
bool NS_BUILD_32_LIKE_64() {
#if defined(NS_BUILD_32_LIKE_64) && NS_BUILD_32_LIKE_64
    return true;
#else
    return false;
#endif
}

/// @function native_dispatch_get_main_queue
///
/// @abstract
/// Returns the default queue that is bound to the main thread.
/// An encapsulation of dispatch_get_main_queue for use with Dart.
///
/// @discussion
/// In order to invoke blocks submitted to the main queue, the application must
/// call dispatch_main(), NSApplicationMain(), or use a CFRunLoop on the main
/// thread.
///
/// The main queue is meant to be used in application context to interact with
/// the main thread and the main runloop.
///
/// Because the main queue doesn't behave entirely like a regular serial queue,
/// it may have unwanted side-effects when used in processes that are not UI apps
/// (daemons). For such processes, the main queue should be avoided.
///
/// @see dispatch_queue_main_t
///
/// @result
/// Returns the main queue. This queue is created automatically on behalf of
/// the main thread before main() is called.
dispatch_queue_main_t native_dispatch_get_main_queue(void) {
    return dispatch_get_main_queue();
}

/// MARK: Objective-C Memory Management

/// You call native_release_object() when you want to prevent an object from being deallocated until you have finished using it.
/// An object is deallocated automatically when its reference count reaches 0. native_release_object() increments the reference count, and native_autorelease_object) decrements it.
/// - Parameter object: The object you want to retain.
void native_retain_object(id object) {
    SEL selector = NSSelectorFromString(@"retain");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object performSelector:selector];
    #pragma clang diagnostic pop
}

/// The object is sent a dealloc message when its reference count reaches 0.
/// - Parameter object: The object you want to release.
void native_release_object(id object) {
    SEL selector = NSSelectorFromString(@"release");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object performSelector:selector];
    #pragma clang diagnostic pop
}

/// Decrements the object's retain count at the end of the current autorelease pool block.
/// - Parameter object: The object you want to release.
void native_autorelease_object(id object) {
    SEL selector = NSSelectorFromString(@"autorelease");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object performSelector:selector];
    #pragma clang diagnostic pop
}
