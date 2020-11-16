import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/runtime/functions.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/native_runtime.dart';
import 'package:ffi/ffi.dart';

/// A wrapper class for Objective-C `Class`.
class Class extends id {
  String name;

  static final Map<int, Class> _cache = <int, Class>{};

  /// Create a class for Objective-C.
  ///
  /// Obtain an existing class by [name], or creating a new class using [name] and
  /// its [superclass].
  factory Class(String name, [Class superclass]) {
    Pointer<Void> ptr = _getClass(name, superclass);
    if (ptr == nullptr) {
      throw 'class $name is not exists!';
    }
    if (_cache.containsKey(ptr.address)) {
      return _cache[ptr.address];
    } else {
      return Class._internal(name, ptr);
    }
  }

  factory Class.fromPointer(Pointer<Void> ptr) {
    if (ptr == nullptr) {
      return null;
    }
    int key = ptr.address;
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      if (object_isClass(ptr) != 0) {
        String name = Utf8.fromUtf8(class_getName(ptr));
        return Class._internal(name, ptr);
      } else {
        throw 'Pointer $ptr is not for Class!';
      }
    }
  }

  Class._internal(this.name, Pointer ptr) : super(ptr) {
    _cache[ptr.address] = this;
  }

  @override
  String toString() {
    return name;
  }
}

Pointer<Void> _getClass(String className, [Class superclass]) {
  if (className == null) {
    className = 'NSObject';
  }
  final classNamePtr = Utf8.toUtf8(className);
  Pointer<Void> basePtr = superclass?.pointer;
  Pointer<Void> result;
  if (superclass == null) {
    result = objc_getClass(classNamePtr);
  } else {
    result = nativeGetClass(classNamePtr, basePtr);
  }
  free(classNamePtr);
  return result;
}
