//
//  DNObjCRuntime.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/17.
//

#import <Foundation/Foundation.h>
#import "DNExtern.h"
#import "DNTypeEncoding.h"
#import "DNMethod.h"

NS_ASSUME_NONNULL_BEGIN

/// Returns an NSMethodSignature object which contains a description of the instance method identified by a given selector.
/// - Parameters:
///   - cls: A class that owns the method.
///   - selector: A Selector that identifies the method for which to return the implementation address.
DN_EXTERN NSMethodSignature * _Nullable native_method_signature(Class cls, SEL selector);

/// Gets type encodings for a signature
/// - Parameters:
///   - signature: The signature.
///   - typeEncodings: Type encodings(out parameter).
///   - decodeRetVal: Whether decode the return value or not.
DN_EXTERN void native_signature_encoding_list(NSMethodSignature *signature, const char * _Nonnull * _Nonnull typeEncodings, BOOL decodeRetVal);

/// Adds a method for class of an instance
/// - Parameters:
///   - instance: An Objective-C instance.
///   - selector: The selector for method.
///   - typeEncodings: Type encodings for method.
///   - returnString: Whether if a method returns a String.
///   - dartImplementation: The implementation for this method, which is a function pointer converted from a dart function by dart:ffi.
///   - dartPort: The port for dart isolate.
DN_EXTERN BOOL native_add_method(id target, SEL selector, char *typeEncodings, bool returnString, DartImplemetion dartImplementation, Dart_Port dartPort);

/// Finds the instance method for selector in protocol and returns its type encodings.
/// - Parameters:
///   - proto: A protocol, has to be implemented by some method.
///   - selector: The selector of method.
DN_EXTERN char * _Nullable native_protocol_method_types(Protocol *proto, SEL selector);

/// Returns the class definition of a specified class name, or creates a new class using a superclass if it's undefined.
/// - Parameters:
///   - className: The class name.
///   - superclass: The class to use as the new class's superclass.
DN_EXTERN Class _Nullable native_get_class(const char *className, Class _Nullable superclass);

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
DN_EXTERN void fillArgsToInvocation(NSMethodSignature *signature, void * _Nonnull * _Nonnull args, NSInvocation *invocation, NSUInteger offset, int64_t stringTypeBitmask, NSMutableArray<NSString *> * _Nullable stringTypeBucket);

/// Invokes an Objective-C method from Dart.
/// @param object The instance or class object.
/// @param selector The selector of method.
/// @param signature The signature of method.
/// @param queue The dispatch queue for async method.
/// @param args Arguments passed to method.
/// @param dartPort The port for dart isolate.
/// @param stringTypeBitmask A bitmask for checking if an argument is a string.
/// @param retType Type of return value(out parameter).
DN_EXTERN void * _Nullable native_instance_invoke(id object,
                                                  SEL selector,
                                                  NSMethodSignature *signature,
                                                  dispatch_queue_t queue,
                                                  void * _Nonnull * _Nullable args,
                                                  void (^callback)(void *),
                                                  Dart_Port dartPort, int64_t
                                                  stringTypeBitmask,
                                                  const char *_Nullable *_Nullable retType);

/// Creates a block object from Dart.
/// @param types Type encodings for creating the block.
/// @param function A function of type BlockFunctionPointer, which would be called when the block is invoking.
/// @param shouldReturnAsync Whether if a block returns a Future to Dart.
/// @param dartPort The port for dart isolate.
DN_EXTERN void *native_block_create(char *types, void *function, BOOL shouldReturnAsync, Dart_Port dartPort);

/// Invokes an Objective-C block from Dart.
/// @param block The block object.
/// @param args Arguments passed to block.
/// @param dartPort The port for dart isolate.
/// @param stringTypeBitmask A bitmask for checking if an argument is a string.
/// @param retType Type of return value(out parameter).
DN_EXTERN void *native_block_invoke(void *block, void * _Nonnull * _Nullable args, Dart_Port dartPort, int64_t stringTypeBitmask, const char *_Nullable *_Nullable retType);

/// Returns a Boolean value that indicates whether macro __LP64__ is enabled.
DN_EXTERN bool LP64(void);

/// Returns a Boolean value that indicates whether macro NS_BUILD_32_LIKE_64 is enabled.
DN_EXTERN bool NS_BUILD_32_LIKE_64(void);

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
DN_EXTERN dispatch_queue_main_t native_dispatch_get_main_queue(void);

/// You call native_release_object() when you want to prevent an object from being deallocated until you have finished using it.
/// An object is deallocated automatically when its reference count reaches 0. native_release_object() increments the reference count, and native_autorelease_object) decrements it.
/// - Parameter object: The object you want to retain.
DN_EXTERN void native_retain_object(id object);

/// The object is sent a dealloc message when its reference count reaches 0.
/// - Parameter object: The object you want to release.
DN_EXTERN void native_release_object(id object);

/// Decrements the object's retain count at the end of the current autorelease pool block.
/// - Parameter object: The object you want to release.
DN_EXTERN void native_autorelease_object(id object);

NS_ASSUME_NONNULL_END
