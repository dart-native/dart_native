import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/runtime/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native
class NSString extends NSSubclass<String> {
  NSString(String value, {InitSubclass init: _new}) : super(value, init);

  NSString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    raw = perform(SEL('UTF8String'));
  }
}

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
    NSObject result = Class('NSString')
        .perform(SEL('stringWithUTF8String:'), args: [value]);
    return result.pointer;
  } else {
    throw 'Invalid param when initializing NSString.';
  }
}

extension ConvertToNSString on String {
  NSString toNSString() => NSString(this);
  NSMutableString toNSMutableString() => NSMutableString(this);
}
