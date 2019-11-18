import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/foundation/nsarray.dart';
import 'package:dart_objc/src/runtime/nssubclass.dart';

class NSDictionary extends NSSubclass<Map> {
  NSDictionary(Map value) : super(value, _new);

  static Pointer<Void> _new(dynamic value) {
    if (value is Map) {
      NSArray keys = value.keys.toList(growable: false).toNSArray();
      NSArray values = value.values.toList(growable: false).toNSArray();
      NSObject result = Class('NSDictionary')
        .perform(Selector('dictionaryWithObjects:forKeys:'), args: [keys, values]);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSDictionary.';
    }
  }
}

extension ConvertToNSDictionary on Map {
  NSDictionary toNSArray() => NSDictionary(this);
}