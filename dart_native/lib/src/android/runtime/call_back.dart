import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:ffi/ffi.dart';

// jni invoke dart function
jniInvokeDart(Function function, Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr, int argCount,
    {bool shouldReturnAsync = false, int responseId = 0}) {
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
    final String resultType =
        argTypesPtrPtr.elementAt(argCount).value.toDartString();
    future.then((value) {
      if (responseId == 0) {
        return;
      }

      if (value == null) {
        asyncInvokeResult(
            responseId, nullptr.cast(), resultType.toNativeUtf8());
        return;
      }

      if (value is String) {
        asyncInvokeResult(responseId, toUtf16(value).cast(),
            'java.lang.String'.toNativeUtf8());
        return;
      }

      dynamic wrapperResult = boxingWrapperClass(value);
      asyncInvokeResult(
          responseId,
          wrapperResult is JObject ? wrapperResult.pointer : wrapperResult,
          resultType.toNativeUtf8());
    });
    return;
  }

  dynamic result = Function.apply(function, args);
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
