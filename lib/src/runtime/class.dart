import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/native_runtime.dart';
import 'package:ffi/ffi.dart';

class Class extends id {
  String name;

  /// An opaque type that represents an Objective-C class.
  Class(this.name, [Class base]) : super(_getClass(name, base)) {
    if (pointer == nullptr) {
      throw 'class $name is not exists!';
    }
  }

  Class.fromPointer(Pointer<Void> ptr) : super(ptr) {
    if (object_isClass(ptr) != 0) {
      name = Utf8.fromUtf8(class_getName(ptr));
    } else {
      throw 'Pointer $ptr is not for Class!';
    }
  }

  @override
  String toString() {
    return name;
  }
}

Pointer<Void> _getClass(String className, [Class base]) {
  if (className == null) {
    className = 'NSObject';
  }
  final classNamePtr = Utf8.toUtf8(className);
  Pointer<Void> basePtr = base?.pointer;
  Pointer<Void> result;
  if (base == null) {
    result = objc_getClass(classNamePtr);
  } else {
    result = nativeGetClass(classNamePtr, basePtr);
  }
  free(classNamePtr);
  return result;
}
