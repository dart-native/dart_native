import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Integer` in Android.
const String jIntegerCls = 'java/lang/Integer';

@native(javaClass: jIntegerCls)
class JInteger extends JSubclass<int> {
  JInteger(int value) : super(value, _new, jIntegerCls);

  JInteger.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, jIntegerCls) {
    raw = callIntMethodSync('intValue');
  }
}

/// New native 'Integer'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject(className: clsName, args: [value]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Integer.';
  }
}
