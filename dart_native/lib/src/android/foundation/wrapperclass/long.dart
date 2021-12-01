import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Long` in Android.
const String cls_long = 'java/lang/Long';

@nativeJavaClass(cls_long)
class JLong extends JSubclass<int> {
  JLong(int value) : super(value, _new, cls_long);

  JLong.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, cls_long) {
    raw = invokeLong('longValue');
  }
}

/// New native 'Long'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject(className: clsName, args: [long(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Long.';
  }
}
