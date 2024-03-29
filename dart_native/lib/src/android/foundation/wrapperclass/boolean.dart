import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Boolean` in Android.
const String _jBooleanCls = 'java/lang/Boolean';

@native(javaClass: _jBooleanCls)
class JBoolean extends JSubclass<bool> {
  JBoolean(bool value) : super(value, _new, _jBooleanCls);

  JBoolean.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, _jBooleanCls) {
    raw = callBoolMethodSync('booleanValue');
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
