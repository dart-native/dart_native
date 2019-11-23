import 'dart:ffi';

import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/selector.dart';

final id nil = id(nullptr);

/// The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects.
class NSObject extends id {
  NSObject([Class isa]) : super(_new(isa));

  NSObject.fromPointer(Pointer<Void> ptr) : super(ptr) {
    if (ptr == null || object_isClass(ptr) != 0) {
      throw 'Pointer $ptr is not for NSObject!';
    }
  }

  static Pointer<Void> _new(Class isa) {
    if (isa == null) {
      isa = Class('NSObject');
    }
    NSObject result = isa.perform(Selector('new'));
    return result.autorelease().pointer;
  }
}

int msg_duration1 = 0;
int msg_duration2 = 0;
int msg_duration3 = 0;
int msg_duration4 = 0;
int msg_duration5 = 0;
