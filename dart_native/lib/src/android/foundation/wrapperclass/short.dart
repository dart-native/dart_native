import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Short` in Android.
const String CLS_SHORT = "java/lang/Short";

class JShort extends JSubclass<int> {
  JShort(int value) : super(value, _new, CLS_SHORT);

  JShort.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_SHORT) {
    raw = invoke("shortValue", [], "S");
  }
}

/// New native 'Short'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject(clsName, args: [short(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Short.';
  }
}
