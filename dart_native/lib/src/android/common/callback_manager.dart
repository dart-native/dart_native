import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/call_back.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/runtime/jobject.dart';
import 'package:ffi/ffi.dart';

void registerCallback(dynamic target, Function function, String functionName) {
  if (target is! JObject) {
    return;
  }
  Pointer<Void> targetPtr = target.pointer.cast<Void>();
  Pointer<Utf8> targetName = target.className!.toNativeUtf8();
  Pointer<Utf8> funNamePtr = functionName.toNativeUtf8();
  CallBackManager.instance.registerCallBack(targetPtr, functionName, function);
  registerNativeCallback!(
      targetPtr, targetName, funNamePtr, _callbackPtr, nativePort);
  calloc.free(targetName);
  calloc.free(funNamePtr);
}

class CallBackManager {
  final Map<Pointer<Void>, Map<String, Function>> _callbackManager = {};

  static final CallBackManager _instance = CallBackManager._internal();
  CallBackManager._internal();
  factory CallBackManager() => _instance;
  static CallBackManager get instance => _instance;

  registerCallBack(
      Pointer<Void> targetPtr, String functionName, Function function) {
    Map<String, Function>? methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      methodsMap = {functionName: function};
    } else {
      methodsMap[functionName] = function;
    }
    _callbackManager[targetPtr] = methodsMap;
  }

  Function? getCallbackFunctionOnTarget(
      Pointer<Void> targetPtr, String functionName) {
    Map<String, Function>? methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      return null;
    }
    return methodsMap[functionName];
  }
}

Pointer<NativeFunction<MethodNativeCallback>> _callbackPtr =
    Pointer.fromFunction(_syncCallback);

void _syncCallback(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    int argCount) {
  String functionName = funNamePtr.cast<Utf8>().toDartString();
  Function? function = CallBackManager.instance
      .getCallbackFunctionOnTarget(targetPtr, functionName);
  if (function == null) {
    argsPtrPtr.elementAt(argCount).value = nullptr.cast();
    return;
  }
  jniInvokeDart(function, argsPtrPtr, argTypesPtrPtr, argCount);
}
