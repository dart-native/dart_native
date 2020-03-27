import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/runtime/nssubclass.dart';

part 'nsstring.g.dart';

@NativeClass()
class NSString extends NSSubclass<String> {
  NSString(String value) : super(value, _new);

  NSString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    value = perform(SEL('UTF8String'));
  }

  static Pointer<Void> _new(dynamic value) {
    if (value is String) {
      NSObject result = Class('NSString')
          .perform(SEL('stringWithUTF8String:'), args: [value]);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSDictionary.';
    }
  }
}

extension ConvertToNSString on String {
  NSString toNSString() => NSString(this);
}
