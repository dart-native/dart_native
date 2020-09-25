//
//  native_runtime.h
//  dart_native
//
//  Created by 杨萧玉 on 2019/10/24.
//

#import "DNMacro.h"
#import "dart_api_dl.h"

@class DNBlockWrapper;
@class DNMethodIMP;
@class DNInvocation;

#ifndef native_runtime_h
#define native_runtime_h

NS_ASSUME_NONNULL_BEGIN

DN_EXTERN NSMethodSignature * _Nullable
native_method_signature(Class cls, SEL selector);

DN_EXTERN void
native_signature_encoding_list(NSMethodSignature *signature, const char * _Nonnull * _Nonnull typeEncodings);

DN_EXTERN BOOL
native_add_method(id target, SEL selector, char *types, void *callback);

DN_EXTERN char * _Nullable
native_protocol_method_types(Protocol *proto, SEL selector);

DN_EXTERN Class _Nullable
native_get_class(const char *className, Class baseClass);

DN_EXTERN void * _Nullable
native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, dispatch_queue_t queue, void * _Nonnull * _Nullable args, BOOL waitUntilDone);

DN_EXTERN void *
native_block_create(char *types, void *callback);

DN_EXTERN void *
native_block_invoke(void *block, void * _Nonnull * _Nullable args);

DN_EXTERN const char * _Nonnull * _Nonnull
native_all_type_encodings(void);

DN_EXTERN const char *
native_type_encoding(const char *str);

DN_EXTERN const char * _Nonnull * _Nullable
native_types_encoding(const char *str, int * _Nullable count, int startIndex);

DN_EXTERN const char * _Nullable
native_struct_encoding(const char *encoding);

DN_EXTERN bool
LP64(void);

DN_EXTERN bool
NS_BUILD_32_LIKE_64(void);

DN_EXTERN dispatch_queue_main_t
_dispatch_get_main_queue(void);

DN_EXTERN void
native_mark_autoreleasereturn_object(id object);

DN_EXTERN const void *
native_convert_nsstring_to_utf16(NSString *string, NSUInteger *length);

#pragma mark - Dart VM API

DN_EXTERN
intptr_t InitDartApiDL(void *data, Dart_Port port);

#pragma mark - Async Block Callback

DN_EXTERN
void NotifyBlockInvokeToDart(DNInvocation *invocation,
                             DNBlockWrapper *wrapper,
                             int numberOfArguments);

#pragma mark - Async Method Callback

DN_EXTERN
void NotifyMethodPerformToDart(DNInvocation *invocation,
                               DNMethodIMP *methodIMP,
                               int numberOfArguments,
                               const char *_Nonnull *_Nonnull types);

#pragma mark - Memory Management

DN_EXTERN
void PassObjectToCUseDynamicLinking(Dart_Handle h, id object);

DN_EXTERN
void NotifyDeallocToDart(intptr_t address);

DN_EXTERN
void RegisterDeallocCallback(void (*callback)(intptr_t));


NS_ASSUME_NONNULL_END

#endif /* native_runtime_h */
