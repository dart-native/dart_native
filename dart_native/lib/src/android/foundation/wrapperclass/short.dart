import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Short` in Android.
const String CLS_SHORT = "java/lang/Short";

class Short extends JSubclass<int> {
  Short(int value) : super(value, _new, CLS_SHORT);

  Short.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_SHORT) {
    raw = invoke("shortValue", [], "S");
  }
}

/// New native 'Short'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [short(value)]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Short.';
  }
}
