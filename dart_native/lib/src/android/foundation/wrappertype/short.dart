import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Short` in Android.
const String clsName = "java/lang/Short";

class Short extends JSubclass<int> {
  Short(int value) : super(value, _new, clsName);

  Short.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsName) {
    raw = invoke("shortValue", [], "()S");
  }
}

/// New native 'Short'.
Pointer<Void> _new(dynamic value) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [short(value)]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Short.';
  }
}
