library dart_native;
import 'dart:io';

import 'package:dart_native/src/android/dart_java.dart';
import 'package:flutter/cupertino.dart';
export 'package:dart_native/src/common/common.dart';
export 'package:dart_native/src/ios/dart_objc.dart';
export 'package:dart_native/src/android/dart_java.dart';
export 'package:dart_native/src/dart_native_root.dn.dart';

class DartNative {
  static void init([String soPath]) {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      DartJava.loadLibrary(soPath);
    }
  }
}
