import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/foundation/internal/native_type_box.dart';
import 'package:dart_objc/src/foundation/collection/nsarray.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/nssubclass.dart';

class NSDictionary extends NSSubclass<Map> {
  NSDictionary(Map value) : super(value, _new) {
    value = Map.of(value);
  }

  NSDictionary.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    NSObject keysObject = perform(Selector('allKeys'));
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
      NSObject result = Class('NSDictionary').perform(
          Selector('dictionaryWithObjects:forKeys:'),
          args: [keys, values]);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSDictionary.';
    }
  }

  int get count => perform(Selector('count'));

  id objectForKey(id key) {
    return perform(Selector('objectForKey:'), args: [key]);
  }
}

extension ConvertToNSDictionary on Map {
  NSDictionary toNSDictionary() => NSDictionary(this);
}
