import 'dart:ffi';

import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/message.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:dart_objc/src/common/pointer_cache.dart';

class NSObject extends id {
  // TODO: remove object from cache when dealloc.

  NSObject({String className}) : super(_new(className).pointer);

  factory NSObject.fromPointer(Pointer<Void> ptr) {
    int key = ptr.address;
    if (ptr_cache.containsKey(key)) {
      return ptr_cache[key];
    } else {
      id instance;
      if (object_isClass(ptr) != 0) {
        instance = Class.fromPointer(ptr);
      } else {
        instance = NSObject._internal(ptr);
      }
      ptr_cache[key] = instance;
      return instance;
    }
  }

  NSObject._internal(Pointer<Void> ptr) : super(ptr) {
    ptr_cache[ptr.address] = this;
  }
}

NSObject _new(String className) {
  return msgSend(Class(className), Selector('new'));
}
