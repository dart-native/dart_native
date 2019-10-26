import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:ffi/ffi.dart';

class Class extends id {
  String name;

  Class(this.name) : super(_getClass(name)) {
    if (pointer == null) {
      // TODO: create class not exists? I prefer NOT.
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

Pointer<Void> _getClass(String className) {
  if (className == null) {
    className = 'NSObject';
  }
  final classNamePtr = Utf8.toUtf8(className);
  Pointer<Void> ptr = objc_getClass(classNamePtr);
  classNamePtr.free();
  return ptr;
}