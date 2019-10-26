import 'dart:ffi';

import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/selector.dart';

final NSObject nil = NSObject.fromPointer(nullptr);

class NSObject extends id {
  NSObject([String className]) : super(_new(className));

  NSObject.fromPointer(Pointer<Void> ptr) : super(ptr) {
    if (ptr == null || object_isClass(ptr) != 0) {
      throw 'Pointer $ptr is not for NSObject!';
    }
  }
}

Pointer<Void> _new(String className) {
  NSObject result = Class(className).perform(Selector('new'));
  return result.pointer;
}
