import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Character` in Android.
const String cls_character = "java/lang/Character";

class JCharacter extends JSubclass<int> {
  JCharacter(int value) : super(value, _new, cls_character);

  JCharacter.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, cls_character) {
    raw = invokeChar("charValue");
  }
}

/// New native 'Character'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject(className: clsName, args: [jchar(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Character.';
  }
}
