import 'dart:ffi';

import 'package:dart_objc/dart_objc.dart';
import 'package:dart_objc/src/common/pointer_encoding.dart';
import 'package:dart_objc/src/foundation/gcd.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/native_runtime.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:ffi/ffi.dart';

Pointer<Void> _msgSend(Pointer<Void> target, Pointer<Void> selector,
    Pointer<Void> signature, Pointer<Pointer<Void>> args, DispatchQueue queue, bool waitUntilDone) {
  Pointer<Void> result;
  Pointer<Void> queuePtr = queue != null ? queue.pointer : nullptr;
  if (waitUntilDone == null) {
    waitUntilDone = true;
  }
  // TODO: This awful code dues to this issue: https://github.com/dart-lang/sdk/issues/39488
  if (args != null && queuePtr != nullptr) {
    result = nativeInvokeMethod(target, selector, signature, queuePtr, args, waitUntilDone ? 1 : 0);
  } else if (args != null) {
    result = nativeInvokeMethodNoQueue(target, selector, signature, args);
  } else if (queuePtr != nullptr) {
    result = nativeInvokeMethodNoArgs(target, selector, signature, queuePtr, waitUntilDone ? 1 : 0);
  } else {
    result = nativeInvokeMethodNoArgsNorQueue(target, selector, signature);
  }
  return result;
}

Map<Pointer, Map<Selector, Pointer>> _methodSignatureCache = {};

dynamic msgSend(id target, Selector selector,
    [List args, bool auto = true, DispatchQueue queue, bool waitUntilDone]) {
  if (target == nil) {
    return nil;
  }
  int start1 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Pointer<Utf8>> typeEncodingsPtrPtr =
      allocate<Pointer<Utf8>>(count: (args?.length ?? 0) + 1);
  Pointer<Void> selectorPtr = selector.toPointer();
  Pointer isaPtr = object_getClass(target.pointer);
  Map<Selector, Pointer> cache = _methodSignatureCache[isaPtr];
  if (cache == null) {
    cache = {};
    _methodSignatureCache[isaPtr] = cache;
  }
  Pointer<Void> signaturePtr = cache[selector];
  if (signaturePtr == null) {
    signaturePtr = nativeMethodSignature(isaPtr, selectorPtr);
    if (signaturePtr.address == 0) {
      throw 'signature for [$target $selector] is NULL.';
    }
    cache[selector] = signaturePtr;
  }
  nativeSignatureEncodingList(signaturePtr, typeEncodingsPtrPtr);

  msg_duration1 += DateTime.now().millisecondsSinceEpoch - start1;

  int start2 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Pointer<Void>> pointers;
  if (args != null) {
    pointers = allocate<Pointer<Void>>(count: args.length);
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg == null) {
        throw 'One of args list is null';
      }
      Pointer<Utf8> argTypePtr =
          nativeTypeEncoding(typeEncodingsPtrPtr.elementAt(i + 1).value);
      String typeEncodings = convertEncode(argTypePtr);
      storeValueToPointer(arg, pointers.elementAt(i), typeEncodings, auto);
    }
  } else if (selector.name.contains(':')) {
    //TODO: need check args count.
    throw 'Arg list not match!';
  }
  msg_duration2 += DateTime.now().millisecondsSinceEpoch - start2;

  int start3 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Void> resultPtr =
      _msgSend(target.pointer, selectorPtr, signaturePtr, pointers, queue, waitUntilDone);
  msg_duration3 += DateTime.now().millisecondsSinceEpoch - start3;
  int start4 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Utf8> resultTypePtr = nativeTypeEncoding(typeEncodingsPtrPtr.value);
  String typeEncodings = convertEncode(resultTypePtr);
  free(typeEncodingsPtrPtr);
  msg_duration4 += DateTime.now().millisecondsSinceEpoch - start4;
  int start5 = DateTime.now().millisecondsSinceEpoch;
  dynamic result = loadValueFromPointer(resultPtr, typeEncodings, auto);
  if (pointers != null) {
    free(pointers);
  }
  msg_duration5 += DateTime.now().millisecondsSinceEpoch - start5;
  return result;
}
