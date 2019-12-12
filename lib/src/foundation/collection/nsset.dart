import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/foundation/collection/nsarray.dart';
import 'package:dart_objc/src/runtime/nssubclass.dart';

class NSSet extends NSSubclass<Set> {
  NSSet(Set value) : super(value, _new) {
    value = Set.of(value);
  }

  NSSet.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    List elements = allObjects.value;
    value = elements.toSet();
  }

  static Pointer<Void> _new(dynamic value) {
    if (value is Set) {
      List list = value.toList(growable: false);
      NSArray array = NSArray(list);
      NSObject result =
          Class('NSSet').perform(Selector('setWithArray:'), args: [array]);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSSet.';
    }
  }

  int get count => perform(Selector('count'));

  NSArray get allObjects {
    NSObject result = perform(Selector('allObjects'));
    return NSArray.fromPointer(result.pointer);
  }
}

extension ConvertToNSSet on Set {
  NSSet toNSSet() => NSSet(this);
}
