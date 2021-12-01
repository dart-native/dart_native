import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Integer` in Android.
const String cls_integer = 'java/lang/Integer';

@native(javaClass: cls_integer)
class JInteger extends JSubclass<int> {
  JInteger(int value) : super(value, _new, cls_integer);

  JInteger.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, cls_integer) {
    raw = invokeInt('intValue');
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
