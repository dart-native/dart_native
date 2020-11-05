import 'dart:ffi';

DynamicLibrary _nativeDylib;
DynamicLibrary get nativeDylib {
  if (_nativeDylib != null) {
    return _nativeDylib;
  }
  _nativeDylib = DynamicLibrary.open('libdart_native.so');
  var dartAPIResult = initializeApi(NativeApi.initializeApiDLData, 1008);
  print("initial result $dartAPIResult");
  return _nativeDylib;
}

final initializeApi = nativeDylib.lookupFunction<
    IntPtr Function(Pointer<Void>, Int64),
    int Function(Pointer<Void>, int)>("InitDartApiDL");
