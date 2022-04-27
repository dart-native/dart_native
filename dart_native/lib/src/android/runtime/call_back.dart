import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';

// jni invoke dart function
jniInvokeDart(Function function, Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr, int argCount,
    {bool shouldReturnAsync = false}) {
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

  if (shouldReturnAsync) {
    Future future = Function.apply(function, args);
    future.then((value) {
      _castToJavaObject(value, argsPtrPtr, argCount);
    });
    return;
  }

  dynamic result = Function.apply(function, args);
  _castToJavaObject(result, argsPtrPtr, argCount);
}

// Dart value convert to java value.
_castToJavaObject(
    dynamic result, Pointer<Pointer<Void>> argsPtrPtr, int argCount) {
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
    return;
  }

  argsPtrPtr.elementAt(argCount).value = nullptr.cast();
}
