import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';

// jni invoke dart function
jniInvokeDart(Function function, Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr, int argCount) {
  List args = [];
  for (var i = 0; i < argCount; i++) {
    Pointer<Utf8> argTypePtr = argTypesPtrPtr.elementAt(i).value;
    Pointer<Void> argPtr = argsPtrPtr.elementAt(i).value;
    if (argPtr == nullptr) {
      args.add(null);
      continue;
    }

    final String argType = argTypePtr.toDartString();
    dynamic arg = argType == 'java.lang.String'
        ? fromUtf16(argPtr)
        : unBoxingWrapperClass(argPtr, argType.replaceAll('.', '/'));
    args.add(arg);
  }

  dynamic result = Function.apply(function, args);

  if (result is Future<Null>) {
    argsPtrPtr.elementAt(argCount).value = nullptr.cast();
    return;
  }

  if (result != null) {
    if (result is String) {
      argsPtrPtr.elementAt(argCount).value = toUtf16(result).cast();
      return;
    }

    dynamic wrapperResult = boxingWrapperClass(result);
    argsPtrPtr.elementAt(argCount).value =
        wrapperResult is JObject ? wrapperResult.pointer : wrapperResult;
  }
}
