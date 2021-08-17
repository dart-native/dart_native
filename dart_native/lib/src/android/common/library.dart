import 'dart:ffi';

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
    IntPtr Function(Pointer<Void>),
    int Function(Pointer<Void>)>("InitDartApiDL");

final _dartAPIResult = initializeApi(NativeApi.initializeApiDLData);

final initDartAPISuccess = _dartAPIResult == 0;

class Library {
  static void setLibPath(String soPath) {
    _libPath = soPath;
  }
}
