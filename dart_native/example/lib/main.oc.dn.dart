// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DartNativeOCGenerator
// **************************************************************************

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/ios/swiftstub.dart';
import 'package:dart_native_example/ios/runtimeson.dart';
import 'package:dart_native_example/ios/runtimestub.dart';

void runOCDartNativeExample() {
  runDartNative();

  registerTypeConvertor('SwiftStub', (ptr) {
    return SwiftStub.fromPointer(ptr);
  });

  registerTypeConvertor('RuntimeSon', (ptr) {
    return RuntimeSon.fromPointer(ptr);
  });

  registerTypeConvertor('RuntimeStub', (ptr) {
    return RuntimeStub.fromPointer(ptr);
  });
}
