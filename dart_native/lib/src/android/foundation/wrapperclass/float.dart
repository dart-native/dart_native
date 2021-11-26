import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Float` in Android.
const String CLS_FLOAT = "java/lang/Float";

class JFloat extends JSubclass<double> {
  JFloat(double value) : super(value, _new, CLS_FLOAT);

  JFloat.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_FLOAT) {
    raw = invokeFloat("floatValue");
  }
}

/// New native 'Float'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is double) {
    JObject object = JObject(clsName, args: [float(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Float.';
  }
}
