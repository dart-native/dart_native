import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/common/precompile_macro.dart';
import 'package:dart_native/src/ios/foundation/nsvalue.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSNumber` in iOS.
@native
class NSNumber extends NSValue {
  NSNumber(dynamic value) : super.fromPointer(_new(value));

  NSNumber.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static Pointer<Void> _new(dynamic value) {
    String typeName = value.runtimeType.toString();
    if (_numberCreationForBoxType.containsKey(typeName)) {
      String selName = 'numberWith${_numberCreationForBoxType[typeName]}:';
      NSObject result = type(of: NSNumber).perform(SEL(selName), args: [value]);
      return result.pointer;
    } else {
      throw 'Unknown type for initializing NSNumber.';
    }
  }
}

Map<String, String> _numberCreationForBoxType = {
  'char': 'Char',
  'unsigned_char': 'UnsignedChar',
  'short': 'Short',
  'unsigned_short': 'UnsignedShort',
  'int': 'Long', // Name conflict. int type for Dart is 64 bit.
  'unsigned_int': 'UnsignedInt',
  'long': 'Long',
  'unsigned_long': 'UnsignedLong',
  'long_long': 'LongLong',
  'unsigned_long_long': 'UnsignedLongLong',
  'float': 'Float',
  'double': 'Double',
  'bool': 'Bool',
  'BOOL': 'Bool',
  'NSInteger': 'Integer',
  'NSUInteger': 'UnsignedInteger',
  'CGFloat': (LP64 ? 'Double' : 'Float'),
  'size_t': (LP64 ? 'UnsignedLong' : 'UnsignedInt'),
};
