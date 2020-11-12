import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/callback_manager.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:ffi/ffi.dart';

void registerCallback(dynamic target, Function function, String functionName) {
  Pointer<Void> targetPtr;
  Pointer<Utf8> targetName;
  if (target is JObject) {
    targetPtr = target.pointer;
    targetName = Utf8.toUtf8(target.className);
  }
  Pointer<Utf8> funNamePtr = Utf8.toUtf8(functionName);
  CallBackManager.instance.registerCallBack(targetPtr, funNamePtr, function);
  registerNativeCallback(targetPtr, targetName, funNamePtr, _callbackPtr);
}

Pointer<NativeFunction<MethodNativeCallback>> _callbackPtr =
  Pointer.fromFunction(_syncCallback);

_callback() {
//  Function function = CallBackManager.instance.getCallbackFunctionOnTarget(targetPtr, funNamePtr);
//
//  dynamic result = Function.apply(function, [1]);
  print("function result: ");
}

void _syncCallback(Pointer<Utf8> test) {
//  _callback(targetPtr);
  print("function result: $test");
}
