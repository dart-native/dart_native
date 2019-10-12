import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/common/pointer_cache.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:ffi/ffi.dart';

class Class extends id {
  String name;

  factory Class(String className) {
    if (className == null) {
      className = 'NSObject';
    }
    final classNamePtr = Utf8.toUtf8(className);
    Pointer<Void> ptr = objc_getClass(classNamePtr);
    classNamePtr.free();
    if (ptr == null) {
      // TODO: create class not exists.
      return null;
    } else if (ptr_cache.containsKey(ptr.address)) {
      return ptr_cache[ptr.address];
    } else {
      return Class._internal(className, ptr);
    }
  }

  factory Class.fromPointer(Pointer<Void> ptr) {
    int key = ptr.address;
    if (ptr_cache.containsKey(key)) {
      return ptr_cache[key];
    } else {
      if (object_isClass(ptr) != 0) {
        String className = Utf8.fromUtf8(class_getName(ptr));
        return Class._internal(className, ptr);
      } else {
        return null;
      }
    }
  }

  Class._internal(this.name, Pointer<Void> ptr) : super(ptr) {
    ptr_cache[ptr.address] = this;
  }
}
