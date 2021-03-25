import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Float` in Android.
const String clsFloat = "java/lang/Float";

class Float extends JSubclass<double> {
  Float(double value) : super(value, _new, clsFloat);

  Float.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsFloat) {
    raw = invoke("floatValue", [], "()F");
  }
}

/// New native 'Float'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is double) {
    JObject object = JObject.parameterConstructor(clsName, [float(value)]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Float.';
  }
}
