import 'dart:ffi';

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

void initSoPath(String? soPath) async {
  if (soPath != null && soPath.isNotEmpty) {
    _libPath = soPath;
    return;
  }

  const dartNativeChannel = MethodChannel("dart_native");
  _libPath = await dartNativeChannel.invokeMethod("getDylibPath");
}
