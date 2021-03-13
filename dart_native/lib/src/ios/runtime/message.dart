import 'dart:ffi';

import 'package:dart_native/src/ios/dart_objc.dart';
import 'package:dart_native/src/ios/common/pointer_encoding.dart';
import 'package:dart_native/src/ios/foundation/gcd.dart';
import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:ffi/ffi.dart';

Pointer<Void> _msgSend(
    Pointer<Void> target,
    Pointer<Void> selector,
    Pointer<Void> signature,
    Pointer<Pointer<Void>> args,
    DispatchQueue queue,
    bool waitUntilDone) {
  Pointer<Void> result;
  Pointer<Void> queuePtr = queue != null ? queue.pointer : nullptr.cast();
  // This awful code dues to this issue: https://github.com/dart-lang/sdk/issues/39488
  if (queuePtr == nullptr) {
    queuePtr = nullptr.cast();
  }
  if (args == null || args == nullptr) {
    args = nullptr.cast();
  }
  if (waitUntilDone == null) {
    waitUntilDone = true;
  }
  result = nativeInvokeMethod(
      target, selector, signature, queuePtr, args, waitUntilDone ? 1 : 0);
  return result;
}

Map<Pointer, Map<SEL, Pointer>> _methodSignatureCache = {};

/// Send a message to [target], which should be an instance in iOS.
///
/// The message will consist of a [selector] and zero or more [args].
/// Return value will be converted to Dart types when [decodeRetVal] is `true`.
/// `C-String` will be converted to Dart `String` when [auto] is `true`.
///
/// You can send message asynchronously to GCD queues using [onQueue]. It will
/// block waiting for the returned result when [waitUntilDone] is `ture`.
dynamic msgSend(Pointer<Void> target, SEL selector,
    {List args,
    bool auto = true,
    DispatchQueue onQueue,
    bool waitUntilDone,
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
  Map<SEL, Pointer> cache = _methodSignatureCache[isaPtr];
  if (cache == null) {
    cache = {};
    _methodSignatureCache[isaPtr] = cache;
  }
  Pointer<Void> signaturePtr = cache[selector];
  if (signaturePtr == null) {
    signaturePtr = nativeMethodSignature(isaPtr, selectorPtr);
    if (signaturePtr.address == 0) {
      calloc.free(typeEncodingsPtrPtr);
      throw 'signature for [$target $selector] is NULL.';
    }
    cache[selector] = signaturePtr;
  }
  nativeSignatureEncodingList(signaturePtr, typeEncodingsPtrPtr);

  List<NSObjectRef> outRefArgs = [];

  Pointer<Pointer<Void>> pointers;
  if (args != null) {
    pointers = calloc<Pointer<Void>>(argCount);
    for (var i = 0; i < argCount; i++) {
      var arg = args[i];
      if (arg == null) {
        arg = nil;
      } else if (arg is NSObjectRef) {
        outRefArgs.add(arg);
      }
      Pointer<Utf8> argTypePtr =
          nativeTypeEncoding(typeEncodingsPtrPtr.elementAt(i + 1).value);
      storeValueToPointer(arg, pointers.elementAt(i), argTypePtr);
    }
  }

  Pointer<Void> resultPtr = _msgSend(
      target, selectorPtr, signaturePtr, pointers, onQueue, waitUntilDone);

  if (pointers != null) {
    calloc.free(pointers);
  }

  if (decodeRetVal) {
    Pointer<Utf8> resultTypePtr = nativeTypeEncoding(typeEncodingsPtrPtr.value);
    calloc.free(typeEncodingsPtrPtr);

    dynamic result = loadValueFromPointer(resultPtr, resultTypePtr, auto);

    outRefArgs.forEach((ref) => ref.syncValue());
    return result;
  } else {
    calloc.free(typeEncodingsPtrPtr);
    return resultPtr;
  }
}
