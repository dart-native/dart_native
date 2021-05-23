import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/callback_manager.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:ffi/ffi.dart';

void registerCallback(dynamic target, Function function, String functionName) {
  if (target is! JObject) {
    print("register error not JObject");
    return;
  }
  Pointer<Void> targetPtr = target.pointer;
  Pointer<Utf8> targetName = target.className.toNativeUtf8();
  Pointer<Utf8> funNamePtr = functionName.toNativeUtf8();
  CallBackManager.instance.registerCallBack(targetPtr, functionName, function);
  registerNativeCallback(targetPtr, targetName, funNamePtr, _callbackPtr, nativePort);
  calloc.free(targetName);
  calloc.free(funNamePtr);
}

Pointer<NativeFunction<MethodNativeCallback>> _callbackPtr =
    Pointer.fromFunction(_syncCallback);

_callback(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    int argCount) {
  String functionName = funNamePtr.cast<Utf8>().toDartString();
  Function function = CallBackManager.instance
      .getCallbackFunctionOnTarget(targetPtr, functionName);
  if (function == null) {
    print("function $functionName not register!!!");
    return null;
  }
  List args = [];
  for (var i = 0; i < argCount; i++) {
    Pointer<Utf8> argTypePtr = argTypesPtrPtr.elementAt(i).value;
    Pointer<Void> argPtr = argsPtrPtr.elementAt(i).value;
    dynamic arg =
        loadValueFromPointer(argPtr, argTypePtr.cast<Utf8>().toDartString());
    args.add(arg);
  }

  dynamic result = Function.apply(function, args);

  if (result != null) {
    storeValueToPointer(result, argsPtrPtr.elementAt(0));
  }
}

void _syncCallback(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    int argCount) {
  _callback(targetPtr, funNamePtr, argsPtrPtr, argTypesPtrPtr, argCount);
}
