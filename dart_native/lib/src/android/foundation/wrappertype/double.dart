import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Double` in Android.
const String CLS_DOUBLE = "java/lang/Double";

class Double extends JSubclass<double> {
  Double(double value) : super(value, _new, CLS_DOUBLE);

  Double.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_DOUBLE) {
    raw = invoke("doubleValue", [], "F");
  }
}

/// New native 'Double'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is double) {
    JObject object = JObject.parameterConstructor(clsName, [value]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Double.';
  }
}
