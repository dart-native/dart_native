// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DartNativeJavaGenerator
// **************************************************************************

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/delegate_stub.dart';
import 'package:dart_native_example/android/entity.dart';
import 'package:dart_native_example/android/runtimestub.dart';

void runJavaDartNativeExample() {
  runDartNative();

  registerJavaTypeConvertor(
      'DelegateStub', 'com/dartnative/dart_native_example/SampleDelegate',
      (ptr) {
    return DelegateStub.fromPointer(ptr);
  });

  registerJavaTypeConvertor(
      'Entity', 'com/dartnative/dart_native_example/Entity', (ptr) {
    return Entity.fromPointer(ptr);
  });

  registerJavaTypeConvertor(
      'RuntimeStub', 'com/dartnative/dart_native_example/RuntimeStub', (ptr) {
    return RuntimeStub.fromPointer(ptr);
  });
}
