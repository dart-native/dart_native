import 'dart:ffi';
import 'dart:isolate';

import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:flutter/services.dart';

DynamicLibrary? _nativeDylib;
DynamicLibrary get nativeDylib {
  _nativeDylib ??= DynamicLibrary.open(_libPath);
  return _nativeDylib!;
}

String _libPath = 'libdart_native.so';

final initializeApi = nativeDylib.lookupFunction<IntPtr Function(Pointer<Void>),
    int Function(Pointer<Void>)>('InitDartApiDL');

final _dartAPIResult = initializeApi(NativeApi.initializeApiDLData);

final initDartAPISuccess = _dartAPIResult == 0;

final interactiveCppRequests = ReceivePort()..listen(requestExecuteCallback);
final int nativePort = interactiveCppRequests.sendPort.nativePort;
final executeCallback = nativeDylib.lookupFunction<Void Function(Pointer<Work>),
    void Function(Pointer<Work>)>('ExecuteCallback');

class Work extends Opaque {}

void requestExecuteCallback(dynamic message) {
  final int workAddress = message;
  final work = Pointer<Work>.fromAddress(workAddress);
  executeCallback(work);
}

Future<void> initSoPath(String? soPath) async {
  if (soPath != null && soPath.isNotEmpty) {
    _libPath = soPath;
    return;
  }

  const dartNativeChannel = MethodChannel("dart_native");
  _libPath = await dartNativeChannel.invokeMethod("getDylibPath");
}
