import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Short` in Android.
const String jShortCls = 'java/lang/Short';

@native(javaClass: jShortCls)
class JShort extends JSubclass<int> {
  JShort(int value) : super(value, _new, jShortCls);

  JShort.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, jShortCls) {
    raw = invokeShort('shortValue');
  }
}

/// New native 'Short'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject(className: clsName, args: [short(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Short.';
  }
}
