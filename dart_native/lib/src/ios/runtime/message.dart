import 'dart:async';
import 'dart:ffi';

import 'package:dart_native/src/ios/common/callback_manager.dart';
import 'package:dart_native/src/ios/dart_objc.dart';
import 'package:dart_native/src/ios/common/pointer_encoding.dart';
import 'package:dart_native/src/ios/foundation/gcd.dart';
import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:dart_native/src/ios/foundation/internal/type_encodings.dart';
import 'package:ffi/ffi.dart';

typedef void _AsyncMessageCallback(dynamic result);

Pointer<Void> _sendMsgToNative(
  Pointer<Void> target,
  Pointer<Void> selector,
  Pointer<Void> signature,
  Pointer<Pointer<Void>>? args,
  DispatchQueue? queue,
  Pointer<Void> callbackPtr,
  int stringTypeBitmask,
  Pointer<Pointer<Utf8>> retType,
) {
  Pointer<Void> result;
  Pointer<Void> queuePtr = queue != null ? queue.pointer : nullptr.cast();
  // This awful code is due to this issue: https://github.com/dart-lang/sdk/issues/39488
  if (queuePtr == nullptr) {
    queuePtr = nullptr.cast();
  }
  if (args == null || args == nullptr) {
    args = nullptr.cast();
  }
  if (callbackPtr == nullptr) {
    callbackPtr = nullptr.cast();
  }
  result = nativeInvokeMethod(target, selector, signature, queuePtr, args,
      callbackPtr, nativePort, stringTypeBitmask, retType);
  return result;
}

Map<Pointer, Map<SEL, Pointer>> _methodSignatureCache = {};

/// Send a message to [target], which should be an instance in iOS.
///
/// The message will consist of a [selector] and zero or more [args].
///
/// You can send message on GCD queues asynchronously using [onQueue]. It will
/// pass the result as a parameter of [callback].
///
/// Returns the result of this message when [callback] is `null`, or `null` if
/// [callback] is passed.
///
/// The Result of the message will be converted to Dart types when
/// [decodeRetVal] is `true`.
dynamic _msgSend(Pointer<Void> target, SEL selector,
    {List? args,
    DispatchQueue? onQueue,
    _AsyncMessageCallback? callback,
    bool decodeRetVal = true}) {
  if (target == nullptr) {
    return;
  }

  int argCount = (args?.length ?? 0);
  // check if count of args match native method.
  if (':'.allMatches(selector.name).length != argCount) {
    throw 'Count of args does not match native method!';
  }

  Pointer<Pointer<Utf8>> typeEncodingsPtrPtr =
      calloc<Pointer<Utf8>>(argCount + 1);
  Pointer<Void> selectorPtr = selector.toPointer();
  Pointer isaPtr = object_getClass(target);
  Map<SEL, Pointer>? cache = _methodSignatureCache[isaPtr];
  if (cache == null) {
    cache = {};
    _methodSignatureCache[isaPtr] = cache;
  }
  Pointer<NativeType>? signaturePtr = cache[selector];
  if (signaturePtr == null) {
    signaturePtr = nativeMethodSignature(isaPtr.cast<Void>(), selectorPtr);
    if (signaturePtr.address == 0) {
      calloc.free(typeEncodingsPtrPtr);
      throw 'signature for [$target $selector] is NULL.';
    }
    cache[selector] = signaturePtr;
  }
  nativeSignatureEncodingList(
      signaturePtr.cast<Void>(), typeEncodingsPtrPtr, decodeRetVal ? 1 : 0);

  List<Pointer<Utf8>> structTypes = [];
  List<NSObjectRef> outRefArgs = [];
  int stringTypeBitmask = decodeRetVal ? 1 << 63 : 0;
  Pointer<Pointer<Void>>? pointers;
  if (args != null) {
    pointers = calloc<Pointer<Void>>(argCount);
    for (var i = 0; i < argCount; i++) {
      var arg = args[i];
      if (arg == null) {
        arg = nil;
      } else if (arg is NSObjectRef) {
        outRefArgs.add(arg);
      }
      if (arg is String) {
        stringTypeBitmask |= (0x1 << i);
      }
      Pointer<Utf8> argTypePtr = typeEncodingsPtrPtr.elementAt(i + 1).value;
      if (argTypePtr.isStruct) {
        structTypes.add(argTypePtr);
      }
      storeValueToPointer(arg, pointers.elementAt(i), argTypePtr);
    }
  }

  Pointer<Void> callbackPtr = nullptr;
  if (callback != null) {
    // Return value is passed to block.
    Block block = Block(callback);
    callbackPtr = block.pointer;
    if (onQueue == null) {
      // Send message to main queue by default.
      onQueue = DispatchQueue.main;
    }
  }

  Pointer<Void> resultPtr = _sendMsgToNative(
      target,
      selectorPtr,
      signaturePtr.cast<Void>(),
      pointers,
      onQueue,
      callbackPtr,
      stringTypeBitmask,
      typeEncodingsPtrPtr);
  if (pointers != null) {
    calloc.free(pointers);
  }

  dynamic result;

  if (callback == null) {
    result = resultPtr;
    // need decode return value
    if (decodeRetVal) {
      Pointer<Utf8> resultTypePtr = typeEncodingsPtrPtr.value;
      // return value is a String.
      if (resultTypePtr.isString) {
        result = loadStringFromPointer(resultPtr);
      } else {
        result = loadValueFromPointer(resultPtr, resultTypePtr);
      }

      if (resultTypePtr.isStruct) {
        structTypes.add(resultTypePtr);
      }
      outRefArgs.forEach((ref) => ref.syncValue());
    }
  }
  // free struct type memory (malloc on native side)
  structTypes.forEach(calloc.free);
  calloc.free(typeEncodingsPtrPtr);
  return result;
}

/// Send a message synchronously to [target], which should be an instance in iOS.
///
/// The message will consist of a [selector] and zero or more [args].
/// Return value will be converted to Dart types when [decodeRetVal] is `true`.
dynamic msgSend(Pointer<Void> target, SEL selector,
    {List? args, bool decodeRetVal = true}) {
  return _msgSend(target, selector, args: args, decodeRetVal: decodeRetVal);
}

/// Send a message to [target] on GCD queues asynchronously using [onQueue].
/// [target] should be an instance in iOS.
/// [onQueue] is `DispatchQueue.main` by default.
///
/// The message will consist of a [selector] and zero or more [args].
/// Return value will be converted to Dart types.
Future<dynamic> msgSendAsync(Pointer<Void> target, SEL selector,
    {List? args, DispatchQueue? onQueue}) async {
  if (onQueue == null) {
    onQueue = DispatchQueue.main;
  }
  final completer = Completer<dynamic>();
  _msgSend(target, selector, args: args, onQueue: onQueue,
      callback: (dynamic result) {
    completer.complete(result);
  });
  return completer.future;
}
