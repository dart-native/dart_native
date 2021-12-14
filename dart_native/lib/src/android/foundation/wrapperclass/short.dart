import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Short` in Android.
const String cls_short = 'java/lang/Short';

@native(javaClass: cls_short)
class JShort extends JSubclass<int> {
  JShort(int value) : super(value, _new, cls_short);

  JShort.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, cls_short) {
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
