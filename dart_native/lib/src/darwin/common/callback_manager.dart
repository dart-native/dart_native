import 'dart:ffi';

import 'dart:isolate';

import 'package:dart_native/src/darwin/common/library.dart';

class CallbackManager {
  // target->selector->function
  final Map<Pointer<Void>, Map<Pointer<Void>, Function>> _callbackManager = {};

  static final CallbackManager _instance = CallbackManager._internal();
  CallbackManager._internal();
  factory CallbackManager() => _instance;
  static CallbackManager get shared => _instance;

  setCallbackForSelectorOnTarget(
      Pointer<Void> targetPtr, Pointer<Void> selectorPtr, Function function) {
    Map<Pointer<Void>, Function>? methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      methodsMap = {selectorPtr: function};
    } else {
      methodsMap[selectorPtr] = function;
    }
    _callbackManager[targetPtr] = methodsMap;
  }

  Function? getCallbackForSelectorOnTarget(
      Pointer<Void> targetPtr, Pointer<Void> selectorPtr) {
    Map<Pointer<Void>, Function>? methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      return null;
    }
    return methodsMap[selectorPtr];
  }

  clearAllCallbackOnTarget(Pointer<Void> ptr) {
    _callbackManager.remove(ptr);
  }
}

final registerDeallocCallback = nativeDylib.lookupFunction<
        Void Function(
            Pointer<NativeFunction<Void Function(IntPtr)>> functionPointer, Int64 dartPort),
        void Function(
            Pointer<NativeFunction<Void Function(IntPtr)>> functionPointer, int dartPort)>(
    'RegisterDeallocCallback');

final interactiveCppRequests = ReceivePort()..listen(requestExecuteCallback);
final int nativePort = interactiveCppRequests.sendPort.nativePort;
final executeCallback = nativeDylib.lookupFunction<Void Function(Pointer<Work>),
    void Function(Pointer<Work>)>('ExecuteCallback');

class Work extends Opaque {}

void requestExecuteCallback(dynamic message) {
  final int workAddress = message;
  if (workAddress == 0) {
    return;
  }
  final work = Pointer<Work>.fromAddress(workAddress);
  executeCallback(work);
}
