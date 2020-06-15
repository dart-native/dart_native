import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:ffi';

class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  String getString(String s) {
    Pointer<Pointer<Void>> pointers;
    pointers = allocate<Pointer<Void>>(count:  1);
    pointers.elementAt(0).cast<Int32>().value = 11;
    nativeInvoke(pointers);
  }
}
