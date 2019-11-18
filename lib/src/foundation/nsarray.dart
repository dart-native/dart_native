import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/runtime/nssubclass.dart';

class NSArray extends NSSubclass<List> {
  NSArray(List value) : super(value, _new);

  static Pointer<Void> _new(dynamic value) {
    if (value is List) {
      NSObject result = Class('NSArray')
        .perform(Selector('arrayWithObjects:'), args: value);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSArray.';
    }
  }
}

extension ConvertToNSArray on List {
  NSArray toNSArray() => NSArray(this);
}