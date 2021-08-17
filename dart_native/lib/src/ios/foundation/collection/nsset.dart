import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/foundation/collection/nsarray.dart';
import 'package:dart_native/src/ios/runtime/internal/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSSet` in iOS.
@native
class NSSet extends NSSubclass<Set> {
  NSSet(Set value, {InitSubclass init: _new}) : super(value, init) {
    value = Set.of(value);
  }

  NSSet.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    List elements = allObjects;
    raw = elements.toSet();
  }

  int get count => perform(SEL('count'));

  List get allObjects {
    Pointer<Void> ptr = perform(SEL('allObjects'), decodeRetVal: false);
    return NSArray.fromPointer(ptr).raw;
  }
}

/// Stands for `NSMutableSet` in iOS.
///
/// Only for type casting. It's unmodifiable.
@native
class NSMutableSet extends NSSet {
  NSMutableSet(Set value) : super(value, init: _mutableCopy);

  NSMutableSet.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static Pointer<Void> _mutableCopy(dynamic value) {
    return NSObject.fromPointer(_new(value)).mutableCopy().pointer;
  }
}

Pointer<Void> _new(dynamic value) {
  if (value is Set) {
    List list = value.toList(growable: false);
    NSArray array = NSArray(list);
    NSObject result =
        Class('NSSet').perform(SEL('setWithArray:'), args: [array]);
    return result.pointer;
  } else {
    throw 'Invalid param when initializing NSSet.';
  }
}

extension ConvertToNSSet on Set {
  NSSet toNSSet() => NSSet(this);
  NSMutableSet toNSMutableSet() => NSMutableSet(this);
}
