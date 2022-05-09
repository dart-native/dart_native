import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Double` in Android.
const String _jDoubleCls = 'java/lang/Double';

@native(javaClass: _jDoubleCls)
class JDouble extends JSubclass<double> {
  JDouble(double value) : super(value, _new, _jDoubleCls);

  JDouble.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, _jDoubleCls) {
    raw = callDoubleMethodSync('doubleValue');
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
