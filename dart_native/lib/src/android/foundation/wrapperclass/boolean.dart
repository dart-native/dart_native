import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Boolean` in Android.
const String CLS_BOOLEAN = "java/lang/Boolean";

class JBoolean extends JSubclass<bool> {
  JBoolean(bool value) : super(value, _new, CLS_BOOLEAN);

  JBoolean.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_BOOLEAN) {
    raw = invoke("booleanValue", [], "Z");
  }
}

/// New native 'Boolean'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is bool) {
    JObject object = JObject.parameterConstructor(clsName, [value]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Boolean.';
  }
}
