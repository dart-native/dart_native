import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/runtime/nssubclass.dart';

class NSString extends NSSubclass<String> {
  NSString(String value) : super(value, _new);

  NSString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    value = perform(Selector('UTF8String'));
  }

  static Pointer<Void> _new(dynamic value) {
    if (value is String) {
      NSObject result = Class('NSString')
          .perform(Selector('stringWithUTF8String:'), args: [value]);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSDictionary.';
    }
  }
}

extension ConvertToNSString on String {
  NSString toNSString() => NSString(this);
}
