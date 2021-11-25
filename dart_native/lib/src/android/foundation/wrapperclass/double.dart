import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Double` in Android.
const String CLS_DOUBLE = "java/lang/Double";

class JDouble extends JSubclass<double> {
  JDouble(double value) : super(value, _new, CLS_DOUBLE);

  JDouble.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_DOUBLE) {
    raw = invoke("doubleValue", [], "D");
  }
}

/// New native 'Double'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is double) {
    JObject object = JObject(clsName, args: [value]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Double.';
  }
}
