//
//  DNObjCRuntime.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/17.
//

#import <Foundation/Foundation.h>
#import "DNExtern.h"
#import "DNTypeEncoding.h"

NS_ASSUME_NONNULL_BEGIN

DN_EXTERN NSMethodSignature * _Nullable native_method_signature(Class cls, SEL selector);

DN_EXTERN void native_signature_encoding_list(NSMethodSignature *signature, const char * _Nonnull * _Nonnull typeEncodings, BOOL decodeRetVal);

DN_EXTERN BOOL native_add_method(id target, SEL selector, char *types, bool returnString, void *callback, Dart_Port dartPort);

DN_EXTERN char * _Nullable native_protocol_method_types(Protocol *proto, SEL selector);

DN_EXTERN Class _Nullable native_get_class(const char *className, Class superclass);

DN_EXTERN void fillArgsToInvocation(NSMethodSignature *signature, void * _Nonnull * _Nonnull args, NSInvocation *invocation, NSUInteger offset, int64_t stringTypeBitmask, NSMutableArray<NSString *> * _Nullable stringTypeBucket);

/// Invoke Objective-C method.
/// @param object instance or class object.
/// @param selector selector of method.
/// @param signature signature of method.
/// @param queue dispatch queue for async method.
/// @param args arguments passed to method.
/// @param dartPort port for dart isolate.
/// @param stringTypeBitmask bitmask for checking if an argument is a string.
/// @param retType type of return value(out parameter).
DN_EXTERN void * _Nullable native_instance_invoke(id object,
                                                  SEL selector,
                                                  NSMethodSignature *signature,
                                                  dispatch_queue_t queue,
                                                  void * _Nonnull * _Nullable args,
                                                  void (^callback)(void *),
                                                  Dart_Port dartPort, int64_t
                                                  stringTypeBitmask,
                                                  const char *_Nullable *_Nullable retType);

DN_EXTERN void *native_block_create(char *types, void *function, BOOL shouldReturnAsync, Dart_Port dartPort);

/// Invoke Objective-C block.
/// @param block block object.
/// @param args arguments passed to block.
/// @param dartPort port for dart isolate.
/// @param stringTypeBitmask bitmask for checking if an argument is a string.
/// @param retType type of return value(out parameter).
DN_EXTERN void *native_block_invoke(void *block, void * _Nonnull * _Nullable args, Dart_Port dartPort, int64_t stringTypeBitmask, const char *_Nullable *_Nullable retType);

DN_EXTERN bool LP64(void);

DN_EXTERN bool NS_BUILD_32_LIKE_64(void);

DN_EXTERN dispatch_queue_main_t _dispatch_get_main_queue(void);

DN_EXTERN void native_retain_object(id object);

DN_EXTERN void native_release_object(id object);

DN_EXTERN void native_autorelease_object(id object);

NS_ASSUME_NONNULL_END
