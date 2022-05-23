import 'dart:ffi';

import 'package:dart_native/src/darwin/common/callback_manager.dart';
import 'package:dart_native/src/darwin/runtime/internal/nsobject_lifecycle.dart';

DynamicLibrary? _nativeDylib;
DynamicLibrary get nativeDylib {
  if (_nativeDylib != null) {
    return _nativeDylib!;
  }
  // Handle dynamic library lazy load
  try {
    // Release mode
    _nativeDylib = DynamicLibrary.open('DartNative.framework/DartNative');
  } catch (e) {
    try {
      // Debug mode and use_frameworks!
      _nativeDylib = DynamicLibrary.open('dart_native.framework/dart_native');
    } catch (e) {
      // Debug mode
      _nativeDylib = _processDylib;
    }
  }
  registerDeallocCallback(nativeObjectDeallocPtr.cast());
  return _nativeDylib!;
}

final DynamicLibrary _processDylib = DynamicLibrary.process();

final initializeApi = nativeDylib.lookupFunction<IntPtr Function(Pointer<Void>),
    int Function(Pointer<Void>)>("InitDartApiDL");

final _dartAPIResult = initializeApi(NativeApi.initializeApiDLData);
final initDartAPISuccess = _dartAPIResult == 0;
