import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/darwin/runtime.dart';
import 'package:dart_native/src/darwin/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/darwin/runtime/internal/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:ffi/ffi.dart';

/// Stands for `NSString` in iOS and macOS.
@native()
class NSString extends NSSubclass<String> {
  NSString(String value, {InitSubclass init = _newNSString})
      : super(value, init);

  NSString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    Pointer<Uint64> length = calloc<Uint64>();
    Pointer<Void> result = convertNSStringToUTF16(ptr, length);
    Uint16List list = result.cast<Uint16>().asTypedList(length.value);
    calloc.free(length);
    raw = String.fromCharCodes(list);
  }
}

/// Stands for `NSMutableString` in iOS and macOS.
///
/// Only for type casting. It's unmodifiable.
@native()
class NSMutableString extends NSString {
  NSMutableString(String value, {InitSubclass init = _newNSMutableString})
      : super(value, init: init);

  NSMutableString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

Pointer<Void> _newNSString(dynamic value) {
  return _new(value, Class('NSString'));
}

Pointer<Void> _newNSMutableString(dynamic value) {
  return _new(value, Class('NSMutableString'));
}

Pointer<Void> _new(dynamic value, Class isa) {
  if (value is String) {
    List<int> units = value.codeUnits;
    Pointer<Uint16> utf16Ptr = units.toUtf16Buffer();
    Pointer<Void> result = isa.perform(SEL('stringWithCharacters:length:'),
        args: [utf16Ptr, units.length], decodeRetVal: false);
    calloc.free(utf16Ptr);
    return result;
  } else {
    throw 'Invalid param when initializing NSString.';
  }
}

extension Utf16Buffer on List<int> {
  Pointer<Uint16> toUtf16Buffer() {
    final count = length + 1;
    final Pointer<Uint16> result = calloc<Uint16>(count);
    final Uint16List typedList = result.asTypedList(count);
    typedList.setAll(0, this);
    typedList[length] = 0;
    return result;
  }
}

extension ConvertToNSString on String {
  NSString toNSString() => NSString(this);
  NSMutableString toNSMutableString() => NSMutableString(this);
}
