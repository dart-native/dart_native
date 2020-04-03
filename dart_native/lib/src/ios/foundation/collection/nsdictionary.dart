import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/foundation/internal/native_type_box.dart';
import 'package:dart_native/src/ios/foundation/collection/nsarray.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@NativeClass()
class NSDictionary extends NSSubclass<Map> {
  NSDictionary(Map value) : super(value, _new) {
    value = Map.of(value);
  }

  NSDictionary.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    NSObject keysObject = perform(SEL('allKeys'));
    NSArray keysArray = NSArray.fromPointer(keysObject.pointer);
    List keysList = keysArray.value;
    Map temp = {};
    for (var i = 0; i < count; i++) {
      id key = keysArray.objectAtIndex(i);
      id value = objectForKey(key);
      temp[keysList[i]] = unboxingElementForDartCollection(value);
    }
    value = temp;
  }

  static Pointer<Void> _new(dynamic value) {
    if (value is Map) {
      NSArray keys = value.keys.toList(growable: false).toNSArray();
      NSArray values = value.values.toList(growable: false).toNSArray();
      NSObject result = Class('NSDictionary')
          .perform(SEL('dictionaryWithObjects:forKeys:'), args: [keys, values]);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSDictionary.';
    }
  }

  int get count => perform(SEL('count'));

  id objectForKey(id key) {
    return perform(SEL('objectForKey:'), args: [key]);
  }
}

extension ConvertToNSDictionary on Map {
  NSDictionary toNSDictionary() => NSDictionary(this);
}
