import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Byte` in Android.
const String cls_byte = 'java/lang/Byte';

@nativeJavaClass(cls_byte)
class JByte extends JSubclass<int> {
  JByte(int value) : super(value, _new, cls_byte);

  JByte.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, cls_byte) {
    raw = invokeByte('byteValue');
  }
}

/// New native 'Byte'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is int) {
    JObject object = JObject(className: clsName, args: [byte(value)]);
    return object.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing Byte.';
  }
}
