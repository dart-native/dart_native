import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Character` in Android.
const String clsName = "java/lang/Character";

class Character extends JSubclass<int> {
  Character(int value) : super(value, _new, clsName);

  Character.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, clsName) {
    raw = invoke("charValue", [], "()C");
  }
}

/// New native 'Character'.
Pointer<Void> _new(dynamic value) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [char(value)]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Character.';
  }
}
