import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:ffi/ffi.dart';

/// Stands for `Class` in iOS and macOS.
///
/// An opaque type that represents an Objective-C class.
class Class extends id {
  String name;

  static final Map<int, Class> _cache = <int, Class>{};

  /// Create a class for Objective-C.
  ///
  /// Obtain an existing class by [name], or creating a new class using [name] and
  /// its [superclass].
  factory Class(String name, [Class? superclass]) {
    Pointer<Void> ptr = _getClass(name, superclass);
    if (ptr == nullptr) {
      throw 'class $name does not exist!';
    }
    if (_cache.containsKey(ptr.address)) {
      return _cache[ptr.address]!;
    } else {
      return Class._internal(name, ptr);
    }
  }

  factory Class.fromPointer(Pointer<Void> ptr) {
    if (ptr == nullptr) {
      throw 'Can\'t initialize a Class with nullptr';
    }
    int key = ptr.address;
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    } else {
      if (object_isClass(ptr) != 0) {
        String name = class_getName(ptr).toDartString();
        return Class._internal(name, ptr);
      } else {
        throw 'Pointer $ptr is not for Class!';
      }
    }
  }

  Class._internal(this.name, Pointer ptr) : super(ptr.cast<Void>()) {
    _cache[ptr.address] = this;
  }

  @override
  String toString() {
    return name;
  }
}

Pointer<Void> _getClass(String? className, [Class? superclass]) {
  className ??= 'NSObject';
  final classNamePtr = className.toNativeUtf8();
  Pointer<Void>? basePtr = superclass?.pointer;
  Pointer<Void> result;
  if (superclass == null) {
    result = objc_getClass(classNamePtr);
  } else {
    result = nativeGetClass(classNamePtr, basePtr!);
  }
  calloc.free(classNamePtr);
  return result;
}
