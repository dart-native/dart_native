import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Double` in Android.
const String cls_double = "java/lang/Double";

class JDouble extends JSubclass<double> {
  JDouble(double value) : super(value, _new, cls_double);

  JDouble.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, cls_double) {
    raw = invokeDouble("doubleValue");
  }
}

/// New native 'Double'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is double) {
    JObject object = JObject(className: clsName, args: [value]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Double.';
  }
}
