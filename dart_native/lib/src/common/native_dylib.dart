import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/src/android/common/library.dart' as library_android
    show nativeDylib;
import 'package:dart_native/src/darwin/common/library.dart' as library_darwin
    show nativeDylib;

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
