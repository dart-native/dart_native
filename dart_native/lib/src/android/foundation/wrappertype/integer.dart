import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Integer` in Android.
const String clsName = "java/lang/Integer";

class Integer extends JSubclass<int> {
  Integer(int value) : super(value, _new, clsName);

  Integer.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsName) {
    raw = invoke("intValue", [], "()I");
  }
}

Pointer<Void> _new(dynamic value) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [value]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Integer.';
  }
}
