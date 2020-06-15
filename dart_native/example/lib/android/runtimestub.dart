import 'dart:convert';

import 'package:dart_native/dart_native.dart';
import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:typed_data';

class RuntimeStub extends JObject {
  RuntimeStub() : super("com.dartnative.dart_native_example.RuntimeStub");

  String getInt(int x) {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    for(int i = 0; i < 10000; i ++){
      invoke("getInt", [x]);
//      print("west flutter get result ${invoke("getInt", [x])}");
    }
    print("west call 10000 time:${new DateTime.now().millisecondsSinceEpoch - startTime}");
    return "aaa";
  }
}
