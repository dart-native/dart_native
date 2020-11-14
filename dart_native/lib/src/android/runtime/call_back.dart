import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/callback_manager.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
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

_callback(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    int argCount
    ) {
  Function function = CallBackManager.instance.getCallbackFunctionOnTarget(targetPtr, funNamePtr);
  if (function == null) {
    return null;
  }
  List args = [];
  print("arg count $argCount");
  for (var i = 0; i < argCount; i++) {
    Pointer<Utf8> argTypePtr = argTypesPtrPtr.elementAt(i).value;
    Pointer<Void> argPtr = argsPtrPtr.elementAt(i).value;
    dynamic arg = loadValueFromPointer(argPtr, Utf8.fromUtf8(argTypePtr.cast()));
    args.add(arg);
  }

  dynamic result = Function.apply(function, args);
}

void _syncCallback(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    int argCount
    ) {
  _callback(targetPtr, funNamePtr, argsPtrPtr, argTypesPtrPtr, argCount);
}
