//
//  DNObjCRuntime.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/17.
//

#import "DNObjCRuntime.h"

#import <objc/runtime.h>

#import "DNMethodIMP.h"
#import "NSString+DartNative.h"
#import "DNBlockCreator.h"
#import "DNObjectDealloc.h"

#if !__has_feature(objc_arc)
#error
#endif

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
    fillArgsToInvocation(signature, args, invocation, 1, stringTypeBitmask, stringTypeBucket);
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
