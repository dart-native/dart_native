import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';

import 'class.dart';

class JObject extends Class {
  //init target class
  JObject(String className) : super(className) {
  }

  dynamic invoke(String methodName, List args) {
    Pointer<Void> invokeMethodRet =
        nativeInvoke();
        return null;
  }
}
