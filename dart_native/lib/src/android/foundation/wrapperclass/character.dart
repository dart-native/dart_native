import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Character` in Android.
const String CLS_CHARACTER = "java/lang/Character";

class Character extends JSubclass<int> {
  Character(int value) : super(value, _new, CLS_CHARACTER);

  Character.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, CLS_CHARACTER) {
    raw = invoke("charValue", [], "C");
  }
}

/// New native 'Character'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject.parameterConstructor(clsName, [char(value)]);
    return object.pointer;
  } else {
    throw 'Invalid param when initializing Character.';
  }
}
