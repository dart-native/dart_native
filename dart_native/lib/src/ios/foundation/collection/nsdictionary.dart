import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/foundation/internal/objc_type_box.dart';
import 'package:dart_native/src/ios/foundation/collection/nsarray.dart';
import 'package:dart_native/src/ios/runtime/internal/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSDictionary` in iOS.
@native
class NSDictionary extends NSSubclass<Map> {
  NSDictionary(Map value, {InitSubclass init: _new}) : super(value, init) {
    value = Map.of(value);
  }

  NSDictionary.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    var keys = allKeys;
    var values = allValues;
    Map temp = {};
    for (var i = 0; i < keys.length; i++) {
      temp[keys[i]] = values;
    }
    raw = temp;
  }

  int get count => perform(SEL('count'));

  List get allKeys {
    Pointer<Void> keysPtr = perform(SEL('allKeys'), decodeRetVal: false);
    return NSArray.fromPointer(keysPtr).raw;
  }

  List get allValues {
    Pointer<Void> valuesPtr = perform(SEL('allValues'), decodeRetVal: false);
    return NSArray.fromPointer(valuesPtr)
        .raw
        .map((e) => unboxingObjCType(e))
        .toList();
  }

  dynamic objectForKey(dynamic key) {
    return perform(SEL('objectForKey:'), args: [key]);
  }
}

/// Stands for `NSMutableDictionary` in iOS.
///
/// Only for type casting. It's unmodifiable.
@native
class NSMutableDictionary extends NSDictionary {
  NSMutableDictionary(Map value) : super(value, init: _mutableCopy);

  NSMutableDictionary.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static Pointer<Void> _mutableCopy(dynamic value) {
    return NSObject.fromPointer(_new(value)).mutableCopy().pointer;
  }
}

Pointer<Void> _new(dynamic value) {
  if (value is Map) {
    NSArray keys = value.keys.toList(growable: false).toNSArray();
    NSArray values = value.values.toList(growable: false).toNSArray();
    NSObject result = Class('NSDictionary')
        .perform(SEL('dictionaryWithObjects:forKeys:'), args: [values, keys]);
    return result.pointer;
  } else {
    throw 'Invalid param when initializing NSDictionary.';
  }
}

extension ConvertToNSDictionary on Map {
  NSDictionary toNSDictionary() => NSDictionary(this);
  NSMutableDictionary toNSMutableDictionary() => NSMutableDictionary(this);
}
