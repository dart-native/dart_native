import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Byte` in Android.
const String _jByteCls = 'java/lang/Byte';

@native(javaClass: _jByteCls)
class JByte extends JSubclass<int> {
  JByte(int value) : super(value, _new, _jByteCls);

  JByte.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, _jByteCls) {
    raw = callByteMethodSync('byteValue');
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
