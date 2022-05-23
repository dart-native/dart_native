//
//  native_runtime.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/24.
//

#import "DNMacro.h"
#import <Foundation/Foundation.h>

@class DNBlockCreator;
@class DNMethodIMP;
@class DNInvocation;

#ifndef native_runtime_h
#define native_runtime_h

/**
 * A port is used to send or receive inter-isolate messages
 */
typedef int64_t Dart_Port;
typedef struct _Dart_Handle* Dart_Handle;
typedef void (^BlockResultCallback)(id _Nullable result, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

NATIVE_TYPE_EXTERN const char *native_type_sint8;
NATIVE_TYPE_EXTERN const char *native_type_sint16;
NATIVE_TYPE_EXTERN const char *native_type_sint32;
NATIVE_TYPE_EXTERN const char *native_type_sint64;
NATIVE_TYPE_EXTERN const char *native_type_uint8;
NATIVE_TYPE_EXTERN const char *native_type_uint16;
NATIVE_TYPE_EXTERN const char *native_type_uint32;
NATIVE_TYPE_EXTERN const char *native_type_uint64;
NATIVE_TYPE_EXTERN const char *native_type_float32;
NATIVE_TYPE_EXTERN const char *native_type_float64;
NATIVE_TYPE_EXTERN const char *native_type_object;
NATIVE_TYPE_EXTERN const char *native_type_class;
NATIVE_TYPE_EXTERN const char *native_type_selector;
NATIVE_TYPE_EXTERN const char *native_type_block;
NATIVE_TYPE_EXTERN const char *native_type_char_ptr;
NATIVE_TYPE_EXTERN const char *native_type_void;
NATIVE_TYPE_EXTERN const char *native_type_ptr;
NATIVE_TYPE_EXTERN const char *native_type_bool;
NATIVE_TYPE_EXTERN const char *native_type_string;

DN_EXTERN void DartNativeSetThrowException(bool canThrow);

DN_EXTERN bool DartNativeCanThrowException(void);

/// Returens true if a pointer is a tagged pointer
/// @param ptr is the pointer to check
DN_EXTERN bool objc_isTaggedPointer(const void *ptr);

/// Returns true if the pointer points to readable and valid memory.
/// @param pointer is the pointer to check
DN_EXTERN bool native_isValidReadableMemory(const void *pointer);

/// Returns true if a pointer is valid
/// @param pointer is the pointer to check
DN_EXTERN bool native_isValidPointer(const void *pointer);

DN_EXTERN NSMethodSignature * _Nullable native_method_signature(Class cls, SEL selector);

DN_EXTERN void native_signature_encoding_list(NSMethodSignature *signature, const char * _Nonnull * _Nonnull typeEncodings, BOOL decodeRetVal);

DN_EXTERN BOOL native_add_method(id target, SEL selector, char *types, bool returnString, void *callback, Dart_Port dartPort);

DN_EXTERN char * _Nullable native_protocol_method_types(Protocol *proto, SEL selector);

DN_EXTERN Class _Nullable native_get_class(const char *className, Class superclass);

/// Return a NSString for utf-16 data
/// @param data data format: [--dataLength(64bit--)][--dataContent(utf16 without BOM)--]
DN_EXTERN NSString *NSStringFromUTF16Data(const unichar *data);

/// Return utf-16 data for NSString. format: [--dataLength(64bit--)][--dataContent(utf16 without BOM)--]
/// @param retVal origin return value
DN_EXTERN uint16_t *UTF16DataFromNSString(NSString *retVal);

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

DN_EXTERN const char * _Nonnull * _Nonnull native_all_type_encodings(void);

DN_EXTERN const char *native_type_encoding(const char *str);

DN_EXTERN const char * _Nonnull * _Nullable native_types_encoding(const char *str, int * _Nullable count, int startIndex);

DN_EXTERN const char * _Nullable native_struct_encoding(const char *encoding);

DN_EXTERN bool LP64(void);

DN_EXTERN bool NS_BUILD_32_LIKE_64(void);

DN_EXTERN dispatch_queue_main_t _dispatch_get_main_queue(void);

DN_EXTERN void native_retain_object(id object);

DN_EXTERN void native_release_object(id object);

DN_EXTERN void native_autorelease_object(id object);

DN_EXTERN const uint16_t *native_convert_nsstring_to_utf16(NSString *string, uint64_t *length);

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

DN_EXTERN bool NotifyDeallocToDart(intptr_t address, Dart_Port dartPort);

DN_EXTERN void RegisterDeallocCallback(void (*callback)(intptr_t));

typedef NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *DartNativeInterfaceMap;
DN_EXTERN NSObject *DNInterfaceHostObjectWithName(char *name);
DN_EXTERN DartNativeInterfaceMap DNInterfaceAllMetaData(void);
DN_EXTERN void DNInterfaceRegisterDartInterface(char *interface, char *method, id block, Dart_Port port);
DN_EXTERN void DNInterfaceBlockInvoke(void *block, NSArray *arguments, BlockResultCallback resultCallback);

NS_ASSUME_NONNULL_END

#endif /* native_runtime_h */
