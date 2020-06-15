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
    Pointer<Int32> pointers = allocate<Int32>(count: 1);
    pointers.value = 4;


    Pointer<Void> paramPointer = generateParamBuffer(pointers);
    Pointer<Int8> temp = paramPointer.cast();
    Int8List list = temp.asTypedList(2);
    list[1] = "w".codeUnitAt(0);
    print("west flutter ${String.fromCharCode(list[1])}");


    Pointer<Pointer<Void>> ppointers = allocate<Pointer<Void>>(count:  1);
    invokeJavaMethod(Utf8.toUtf8(""), Utf8.toUtf8(""), ppointers);

    releaseParamBuffer();

    invoke("", null);
  }
}
