import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'library.dart';

class CallBackManager {
  Map<Pointer<Void>, Map<String, Function>> _callbackManager = {};

  static final CallBackManager _instance = CallBackManager._internal();
  CallBackManager._internal();
  factory CallBackManager() => _instance;
  static CallBackManager get instance => _instance;

  registerCallBack(Pointer<Void> targetPtr, String functionName, Function function) {
    Map<String, Function> methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      methodsMap = {functionName : function};
    } else {
      methodsMap[functionName] = function;
    }
    _callbackManager[targetPtr] = methodsMap;
  }

  Function getCallbackFunctionOnTarget(
      Pointer<Void> targetPtr, String functionName) {
    Map<String, Function> methodsMap = _callbackManager[targetPtr];
    if (methodsMap == null) {
      return null;
    }
    return methodsMap[functionName];
  }
}

final interactiveCppRequests = ReceivePort()..listen(requestExecuteCallback);
final int nativePort = interactiveCppRequests.sendPort.nativePort;
final executeCallback = nativeDylib.lookupFunction<Void Function(Pointer<Work>),
    void Function(Pointer<Work>)>('ExecuteCallback');

class Work extends Struct {}

void requestExecuteCallback(dynamic message) {
  final int workAddress = message;
  final work = Pointer<Work>.fromAddress(workAddress);
  executeCallback(work);
}
