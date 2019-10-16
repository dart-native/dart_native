import 'dart:ffi';

import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/selector.dart';

final NSObject nil = NSObject.fromPointer(nullptr);

class NSObject extends id {
  factory NSObject({String className}) {
    return Class(className).perform(Selector('new'));
  }
  
  factory NSObject.fromPointer(Pointer<Void> ptr) {
    if (object_isClass(ptr) != 0) {
      return null;
    } else {
      // TODO: convert to subclass.
      return NSObject._internal(ptr);
    }
  }

  NSObject._internal(Pointer<Void> ptr) : super(ptr);
}

