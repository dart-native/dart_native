import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Byte` in Android.
const String clsName = "java/lang/Byte";

class Byte extends JSubclass<int> {
  Byte(int value) : super(value, _new, clsName);

  Byte.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsName) {
    raw = invoke("byteValue", [], "()B");
  }
}

/// New native 'Byte'.
Pointer<Void> _new(dynamic value) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [byte(value)]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Byte.';
  }
}
