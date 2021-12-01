import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Boolean` in Android.
const String cls_boolean = 'java/lang/Boolean';

@nativeJavaClass(cls_boolean)
class JBoolean extends JSubclass<bool> {
  JBoolean(bool value) : super(value, _new, cls_boolean);

  JBoolean.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, cls_boolean) {
    raw = invokeBool('booleanValue');
  }
}

/// New native 'Boolean'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is bool) {
    JObject object = JObject(className: clsName, args: [value]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Boolean.';
  }
}
