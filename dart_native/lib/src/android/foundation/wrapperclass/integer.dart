import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Integer` in Android.
const String _jIntegerCls = 'java/lang/Integer';

@native(javaClass: _jIntegerCls)
class JInteger extends JSubclass<int> {
  JInteger(int value) : super(value, _new, _jIntegerCls);

  JInteger.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, _jIntegerCls) {
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
