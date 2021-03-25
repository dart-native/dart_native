import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Integer` in Android.
const String clsInteger = "java/lang/Integer";

class Integer extends JSubclass<int> {
  Integer(int value) : super(value, _new, clsInteger);

  Integer.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsInteger) {
    raw = invoke("intValue", [], "()I");
  }
}

/// New native 'Integer'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [value]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Integer.';
  }
}
