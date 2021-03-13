import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/internal/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:ffi/ffi.dart';

/// Stands for `NSString` in iOS.
@native
class NSString extends NSSubclass<String> {
  NSString(String value, {InitSubclass init: _new}) : super(value, init);

  NSString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    Pointer<Uint64> length = calloc<Uint64>();
    Pointer<Void> result = convertNSStringToUTF16(ptr, length);
    Uint16List list = result.cast<Uint16>().asTypedList(length.value);
    calloc.free(length);
    raw = String.fromCharCodes(list);
  }
}

/// Stands for `NSMutableString` in iOS.
///
/// Only for type casting. It's unmodifiable.
@native
class NSMutableString extends NSString {
  NSMutableString(String value) : super(value, init: _mutableCopy);

  NSMutableString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static Pointer<Void> _mutableCopy(dynamic value) {
    return NSObject.fromPointer(_new(value)).mutableCopy().pointer;
  }
}

Pointer<Void> _new(dynamic value) {
  if (value is String) {
    final units = value.codeUnits;
    final Pointer<Uint16> charPtr = calloc<Uint16>(units.length + 1);
    final Uint16List nativeString = charPtr.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    NSObject result = Class('NSString').perform(
        SEL('stringWithCharacters:length:'),
        args: [charPtr, units.length]);
    calloc.free(charPtr);
    return result.pointer;
  } else {
    throw 'Invalid param when initializing NSString.';
  }
}

extension ConvertToNSString on String {
  NSString toNSString() => NSString(this);
  NSMutableString toNSMutableString() => NSMutableString(this);
}
