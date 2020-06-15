import 'dart:convert';

import 'package:dart_native/dart_native.dart';
import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:typed_data';

class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  String getString(String s) {
    // invoke("", [1, 2]);
    return "aaa";
  }
}
