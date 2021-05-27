import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `String` in Android.
final _clsString = "java/lang/String";

class JString extends JSubclass<String> {
  JString(String value) : super(value, _new, _clsString);

  JString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, _clsString) {
    raw = "string";
  }
}

/// New native 'JString'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is String) {
    final units = value.codeUnits;
    final Pointer<Uint16> charPtr = allocate<Uint16>(count: units.length + 1);
    final Uint16List nativeString = charPtr.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    Pointer javaStringPtr = dartStringToJavaString(charPtr, units.length);
    free(charPtr);
    return javaStringPtr;
  } else {
    throw 'Invalid param when initializing JString.';
  }
}
