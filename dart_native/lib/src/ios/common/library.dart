import 'dart:ffi';

DynamicLibrary _runtimeLib;
DynamicLibrary get runtimeLib {
  if (_runtimeLib != null) {
    return _runtimeLib;
  }
  try {
    _runtimeLib = DynamicLibrary.open('dart_native.framework/dart_native');
  } catch (e) {
    // static linking
    _runtimeLib = nativeDylib;
  }
  return _runtimeLib;
}

final DynamicLibrary nativeDylib = DynamicLibrary.process();
