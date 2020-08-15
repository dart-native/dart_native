import 'dart:ffi';

import 'package:dart_native/src/ios/common/callback_manager.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';

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
  registerDeallocCallback(nativeObjectDeallocPtr.cast());
  return _runtimeLib;
}

final DynamicLibrary nativeDylib = DynamicLibrary.process();

final initializeApi = runtimeLib.lookupFunction<
    IntPtr Function(Pointer<Void>, Int64),
    int Function(Pointer<Void>, int)>("InitDartApiDL");

final _dartAPIResult = initializeApi(NativeApi.initializeApiDLData, nativePort);

final initDartAPISuccess = _dartAPIResult == 0;
