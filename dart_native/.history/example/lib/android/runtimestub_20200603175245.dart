import 'dart:convert';

import 'package:dart_native/dart_native.dart';
import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:typed_data';

class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  int getInt(int i) {
    return invoke('getInt', '(I)I', [i]);
  }

  double getDouble(double b) {
    return invoke('getDouble', '(D)D', [b]);
  }

  int getByte(int b) {
    return invoke('getByte', '(B)B', [b]);
  }

  double getFloat(double f) {
    return invoke('getFloat', '(F)F', [f]);
  }

  String getChar(String c) {
    return invoke('getChar', '(C)C', [c]);
  }

  int getShort(int s) {
    return invoke('getShort', '(S)S', [s]);
  }

  int getLong(int l) {
    return invoke('getLong', '(J)J', [l]);
  }

  bool getBool(bool b) {
    return invoke('getBool', '(Z)Z', [b]);
  }

  String getString(String s) {
    Pointer<Int32> pointers = allocate<Int32>(count: 1);
    pointers.value = 2;


    Pointer<Void> paramPointer = generateParamBuffer(pointers);
    // Pointer<Int8> temp = paramPointer.cast();
    // Int8List list = temp.asTypedList(2);
    // list[1] = "y".codeUnitAt(0);
    // print("west1 ${ String.fromCharCode(list[1])}");


    // Pointer<Pointer<Void>> ppointers = allocate<Pointer<Void>>(count:  1);
    // invokeJavaMethod(Utf8.toUtf8(""), Utf8.toUtf8(""), ppointers);

    // releaseParamBuffer();
  }

  int add(int a, int b) {
    return invoke('add', '(II)I', [a, b]);
  }

  void log(String a, String b) {
    return invoke('log', '(Ljava/lang/String;Ljava/lang/String;)V', [a, b]);
  }

  bool complexCall(String s, int i, String c, double d, double f, int b, int sh, int l, bool boo) {
    return invoke('complexCall', '(Ljava/lang/String;ICDFBSJZ)Z', [s, i, c, d, f, b, sh, l, boo]);
  }

//  JObject getObject(JObject object) {
//    return invoke('getObject', [object]);
//  }
}
