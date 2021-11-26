import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Long` in Android.
const String CLS_LONG = "java/lang/Long";

class JLong extends JSubclass<int> {
  JLong(int value) : super(value, _new, CLS_LONG);

  JLong.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_LONG) {
    raw = invokeLong("longValue");
  }
}

/// New native 'Long'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject(clsName, args: [long(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Long.';
  }
}
