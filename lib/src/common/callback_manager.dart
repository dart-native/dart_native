import 'dart:ffi';

import 'package:dart_objc/src/runtime/id.dart';

class CallbackManager {
  // target->selector->function
  Map<Pointer<Void>, Map<Pointer<Void>, Function>> _callbackManager = {};

  static final CallbackManager _instance = CallbackManager._internal();
  CallbackManager._internal();
  factory CallbackManager() => _instance;
  static CallbackManager get shared => _instance;

  setCallbackForSelectorOnTarget(
      Pointer<Void> targetPtr, Pointer<Void> selectorPtr, Function function) {
    Map<Pointer<Void>, Function> methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      methodsMap = {selectorPtr: function};
    } else {
      methodsMap[selectorPtr] = function;
    }
    _callbackManager[targetPtr] = methodsMap;
  }

  Function getCallbackForSelectorOnTarget(
      Pointer<Void> targetPtr, Pointer<Void> selectorPtr) {
    Map<Pointer<Void>, Function> methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      return null;
    }
    return methodsMap[selectorPtr];
  }

  clearAllCallbackOnTarget(id target) {
    _callbackManager.remove(target.pointer);
  }
}
