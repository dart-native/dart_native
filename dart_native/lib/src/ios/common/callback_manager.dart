import 'dart:ffi';

import 'dart:isolate';

import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';

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

  clearAllCallbackOnTarget(Pointer<Void> ptr) {
    _callbackManager.remove(ptr);
  }
}

final registerDeallocCallback = runtimeLib.lookupFunction<
        Void Function(
            Pointer<NativeFunction<Void Function(IntPtr)>> functionPointer),
        void Function(
            Pointer<NativeFunction<Void Function(IntPtr)>> functionPointer)>(
    'RegisterDeallocCallback');

final interactiveCppRequests = ReceivePort()..listen(requestExecuteCallback);
final int nativePort = interactiveCppRequests.sendPort.nativePort;
final executeCallback = runtimeLib.lookupFunction<Void Function(Pointer<Work>),
    void Function(Pointer<Work>)>('ExecuteCallback');

class Work extends Struct {}

void requestExecuteCallback(dynamic message) {
  final int workAddress = message;
  final work = Pointer<Work>.fromAddress(workAddress);
  executeCallback(work);
}
