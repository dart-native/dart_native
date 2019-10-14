import 'dart:ffi';

import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/message.dart';
import 'package:dart_objc/src/runtime/selector.dart';

final Pointer<Void> nil = Pointer.fromAddress(0);

class NSObject extends id {
  NSObject({String className}) : super(_new(className).pointer);

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

NSObject _new(String className) {
  return msgSend(Class(className), Selector('new'));
}
