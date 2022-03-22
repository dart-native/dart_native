import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Float` in Android.
const String jFloatCls = 'java/lang/Float';

@native(javaClass: jFloatCls)
class JFloat extends JSubclass<double> {
  JFloat(double value) : super(value, _new, jFloatCls);

  JFloat.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, jFloatCls) {
    raw = callFloatMethodSync('floatValue');
  }
}

/// New native 'Float'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is double) {
    JObject object = JObject(className: clsName, args: [float(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Float.';
  }
}
