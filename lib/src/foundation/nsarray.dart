import 'dart:ffi';

import 'package:dart_objc/foundation.dart';
import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/foundation/native_type_box.dart';
import 'package:dart_objc/src/foundation/nsnumber.dart';
import 'package:dart_objc/src/foundation/nsset.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/nssubclass.dart';
import 'package:ffi/ffi.dart';

class NSArray extends NSSubclass<List> {
  NSArray(List value) : super(value, _new) {
    value = List.of(value, growable: false);
  }

  NSArray.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    int count = perform(Selector('count'));
    List temp = List(count);
    for (var i = 0; i < count; i++) {
      id e = objectAtIndex(i);
      temp[i] = unboxingElementForDartCollection(e);
    }
    value = temp;
  }

  static Pointer<Void> _new(dynamic value) {
    if (value is List) {
      List boxValues = value.map((e) {
        return boxingElementForNativeCollection(e);
      }).toList();
      Pointer<Pointer<Void>> listPtr = allocate(count: boxValues.length);
      for (var i = 0; i < boxValues.length; i++) {
        listPtr.elementAt(i).value = boxValues[i].pointer;
      }
      NSObject result =
          Class('NSArray').perform(Selector('arrayWithObjects:count:'), args: [listPtr, boxValues.length]);
      free(listPtr);
      return result.pointer;
    } else {
      throw 'Invalid param when initializing NSArray.';
    }
  }

  int get count => perform(Selector('count'));

  id objectAtIndex(int index) {
    return perform(Selector('objectAtIndex:'), args: [index]);
  }
}

id boxingElementForNativeCollection(dynamic e) {
  if (e is num || e is NativeBox || e is bool) {
    return NSNumber(e);
  } else if (e is NativeStruct) {
    return NSValue.valueWithStruct(e);
  } else if (e is String) {
    return NSString(e);
  } else if (e is id) {
    return e;
  } else if (e is List) {
    return NSArray(e);
  } else if (e is Map) {
    return NSDictionary(e);
  } else if (e is Set) {
    return NSSet(e);
  } else {
    throw 'Cannot boxing element $e';
  }
}

dynamic unboxingElementForDartCollection(id e) {
  if (e is id) {
    if (e.isKind(of: type(of: NSValue))) {
      return NSValue.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSString))) {
      return NSString.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSArray))) {
      return NSArray.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSDictionary))) {
      return NSDictionary.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSSet))) {
      return NSSet.fromPointer(e.pointer).value;
    } else {
      return e;
    }
  } else {
    throw 'Cannot unboxing element $e';
  }
}

extension ConvertToNSArray on List {
  NSArray toNSArray() => NSArray(this);
}
