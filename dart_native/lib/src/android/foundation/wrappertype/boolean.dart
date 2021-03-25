import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Boolean` in Android.
const String clsName = "java/lang/Boolean";

class Boolean extends JSubclass<bool> {
  Boolean(bool value) : super(value, _new, clsName);

  Boolean.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsName) {
    raw = invoke("booleanValue", [], "()Z");
  }
}

/// New native 'Boolean'.
Pointer<Void> _new(dynamic value) {
  if (value is bool) {
    JObject object = JObject.parameterConstructor(clsName, [value]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Boolean.';
  }
}
