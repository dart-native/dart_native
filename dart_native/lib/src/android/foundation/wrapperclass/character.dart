import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Character` in Android.
const String jCharacterCls = 'java/lang/Character';

@native(javaClass: jCharacterCls)
class JCharacter extends JSubclass<int> {
  JCharacter(int value) : super(value, _new, jCharacterCls);

  JCharacter.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, jCharacterCls) {
    raw = callCharMethodSync('charValue');
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
