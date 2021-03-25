import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Long` in Android.
const String clsLong = "java/lang/Long";

class Long extends JSubclass<int> {
  Long(int value) : super(value, _new, clsLong);

  Long.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsLong) {
    raw = invoke("longValue", [], "()J");
  }
}

/// New native 'Long'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [long(value)]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Long.';
  }
}
