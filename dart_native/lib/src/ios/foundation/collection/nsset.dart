import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/foundation/collection/nsarray.dart';
import 'package:dart_native/src/ios/runtime/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@NativeClass()
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
          Class('NSSet').perform(SEL('setWithArray:'), args: [array]);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSSet.';
    }
  }

  int get count => perform(SEL('count'));

  NSArray get allObjects {
    NSObject result = perform(SEL('allObjects'));
    return NSArray.fromPointer(result.pointer);
  }
}

extension ConvertToNSSet on Set {
  NSSet toNSSet() => NSSet(this);
}
