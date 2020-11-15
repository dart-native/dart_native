import 'dart:ffi';

import 'package:dart_native/src/android/common/callback_manager.dart';

DynamicLibrary _nativeDylib;
DynamicLibrary get nativeDylib {
  if (_nativeDylib != null) {
    return _nativeDylib;
  }
  _nativeDylib = DynamicLibrary.open('libdart_native.so');
  return _nativeDylib;
}

final initializeApi = nativeDylib.lookupFunction<
    IntPtr Function(Pointer<Void>, Int64),
    int Function(Pointer<Void>, int)>("InitDartApiDL");

final _dartAPIResult = initializeApi(NativeApi.initializeApiDLData, nativePort);

final initDartAPISuccess = _dartAPIResult == 0;
