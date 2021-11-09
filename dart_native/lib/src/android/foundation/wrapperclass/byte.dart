import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Byte` in Android.
const String CLS_BYTE = "java/lang/Byte";

class JByte extends JSubclass<int> {
  JByte(int value) : super(value, _new, CLS_BYTE);

  JByte.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_BYTE) {
    raw = invoke("byteValue", [], "B");
  }
}

/// New native 'Byte'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [value]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Byte.';
  }
}
