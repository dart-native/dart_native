import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/objc_type_box.dart';
import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/runtime/internal/nssubclass.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSArray` in iOS.
@native
class NSArray extends NSSubclass<List> {
  NSArray(List value, {InitSubclass init: _new}) : super(value, init) {
    value = List.of(value, growable: false);
  }

  NSArray.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    int count = perform(SEL('count'));
    List temp = List(count);
    for (var i = 0; i < count; i++) {
      var e = objectAtIndex(i);
      temp[i] = unboxingObjCType(e);
    }
    raw = temp;
  }

  int get count => perform(SEL('count'));

  dynamic objectAtIndex(int index) {
    return perform(SEL('objectAtIndex:'), args: [index]);
  }
}

/// Stands for `NSMutableArray` in iOS.
///
/// Only for type casting. It's unmodifiable.
@native
class NSMutableArray extends NSArray {
  NSMutableArray(List value) : super(value, init: _mutableCopy) {
    value = List.of(value, growable: true);
  }

  NSMutableArray.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static Pointer<Void> _mutableCopy(dynamic value) {
    return NSObject.fromPointer(_new(value)).mutableCopy().pointer;
  }
}

Pointer<Void> _new(dynamic value) {
  if (value is List) {
    List boxValues = value.map((e) {
      return boxingObjCType(e);
    }).toList();
    Pointer<Pointer<Void>> listPtr = allocate(count: boxValues.length);
    for (var i = 0; i < boxValues.length; i++) {
      listPtr.elementAt(i).value = boxValues[i].pointer;
    }
    NSObject result = Class('NSArray').perform(SEL('arrayWithObjects:count:'),
        args: [listPtr, boxValues.length]);
    free(listPtr);
    return result.pointer;
  } else {
    throw 'Invalid param when initializing NSArray.';
  }
}

extension ConvertToNSArray on List {
  NSArray toNSArray() => NSArray(this);
  NSMutableArray toNSMutableArray() => NSMutableArray(this);
}
