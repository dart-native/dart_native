import 'dart:ffi';

import 'package:dart_native/src/android/common/callback_manager.dart';

DynamicLibrary _nativeDylib;
DynamicLibrary get nativeDylib {
  if (_nativeDylib == null) {
    print("dylib is null, open dyLibrary path + $_libPath");
    _nativeDylib = DynamicLibrary.open(_libPath);
  }
  return _nativeDylib;
}

String _libPath = "libdart_native.so";

final initializeApi = nativeDylib.lookupFunction<
    IntPtr Function(Pointer<Void>, Int64),
    int Function(Pointer<Void>, int)>("InitDartApiDL");

final _dartAPIResult = initializeApi(NativeApi.initializeApiDLData, nativePort);

final initDartAPISuccess = _dartAPIResult == 0;


class Library {
  static void setLibPath(String soPath) {
    _libPath = soPath;
  }
}
