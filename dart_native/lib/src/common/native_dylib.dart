import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/src/android/common/library.dart' as library_android
    show nativeDylib, nativePort;

import 'package:dart_native/src/darwin/common/library.dart' as library_darwin
    show nativeDylib;
import 'package:dart_native/src/darwin/common/callback_manager.dart'
    as callback_darwin show nativePort;

DynamicLibrary? _nativeDylib;
DynamicLibrary get nativeDylib {
  if (_nativeDylib != null) {
    return _nativeDylib!;
  }

  if (Platform.isIOS || Platform.isMacOS) {
    _nativeDylib = library_darwin.nativeDylib;
  } else if (Platform.isAndroid) {
    _nativeDylib = library_android.nativeDylib;
  } else {
    throw 'Platform not supported: ${Platform.localeName}';
  }

  return _nativeDylib!;
}

int _nativePort = 0;
int get nativePort {
  if (_nativePort != 0) {
    return _nativePort;
  }

  if (Platform.isIOS || Platform.isMacOS) {
    _nativePort = callback_darwin.nativePort;
  } else if (Platform.isAndroid) {
    _nativePort = library_android.nativePort;
  } else {
    throw 'Platform not supported: ${Platform.localeName}';
  }

  return _nativePort;
}
