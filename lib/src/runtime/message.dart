import 'dart:ffi';

import 'package:dart_objc/src/common/pointer_encoding.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/native_runtime.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:ffi/ffi.dart';

Pointer<Void> _msgSend(
    Pointer<Void> target, Pointer<Void> selector, Pointer<Void> signature,
    [Pointer<Pointer<Void>> args]) {
  Pointer<Void> result;
  if (args != null) {
    result = nativeInvokeMethod(target, selector, signature, args);
  } else {
    result = nativeInvokeMethodNoArgs(target, selector, signature);
  }
  return result;
}

dynamic msgSend(id target, Selector selector, [List args, bool auto = true]) {
  if (target == nil) {
    return null;
  }
  // int start1 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Pointer<Utf8>> typeEncodingsPtrPtr =
      Pointer<Pointer<Utf8>>.allocate(count: (args?.length ?? 0) + 1);
  Pointer<Void> selectorPtr = selector.toPointer();

  Pointer<Void> signature =
      nativeMethodSignature(target.pointer, selectorPtr, typeEncodingsPtrPtr);
  if (signature.address == 0) {
    throw 'signature for [$target $selector] is NULL.';
  }
  // msg_duration1 += DateTime.now().millisecondsSinceEpoch - start1;

  // int start2 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Pointer<Void>> pointers;
  if (args != null) {
    pointers = Pointer<Pointer<Void>>.allocate(count: args.length);
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg == null) {
        throw 'One of args list is null';
      }
      Pointer<Utf8> argTypePtr =
          nativeTypeEncoding(typeEncodingsPtrPtr.elementAt(i + 1).load());
      String typeEncodings = convertEncode(argTypePtr);
      storeValueToPointer(arg, pointers.elementAt(i), typeEncodings, auto);
    }
  } else if (selector.name.contains(':')) {
    //TODO: need check args count.
    throw 'Arg list not match!';
  }
  // msg_duration2 += DateTime.now().millisecondsSinceEpoch - start2;

  // int start3 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Void> resultPtr =
      _msgSend(target.pointer, selectorPtr, signature, pointers);
  // msg_duration3 += DateTime.now().millisecondsSinceEpoch - start3;
  // int start4 = DateTime.now().millisecondsSinceEpoch;
  Pointer<Utf8> resultTypePtr = nativeTypeEncoding(typeEncodingsPtrPtr.load());
  String typeEncodings = convertEncode(resultTypePtr);
  typeEncodingsPtrPtr.free();
  // msg_duration4 += DateTime.now().millisecondsSinceEpoch - start4;
  // int start5 = DateTime.now().millisecondsSinceEpoch;
  dynamic result = loadValueFromPointer(resultPtr, typeEncodings, auto);
  if (pointers != null) {
    pointers.free();
  }
  // msg_duration5 += DateTime.now().millisecondsSinceEpoch - start5;
  return result;
}

String convertEncode(Pointer<Utf8> ptr) {
  if (_encodeCache.containsKey(ptr)) {
    return _encodeCache[ptr];
  }
  String result = Utf8.fromUtf8(ptr);
  _encodeCache[ptr] = result;
  return result;
}

Map<Pointer<Utf8>, String> _encodeCache = {};
