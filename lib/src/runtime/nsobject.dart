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

  NSObject.alloc([Class isa]) : super(_alloc(isa));

  NSObject init() {
    return perform(Selector('init'));
  }

  NSObject copy() {
    NSObject result = perform(Selector('copy'));
    return NSObject.fromPointer(result.autorelease().pointer);
  }

  NSObject mutableCopy() {
    NSObject result = perform(Selector('mutableCopy'));
    return NSObject.fromPointer(result.autorelease().pointer);
  }

  static Pointer<Void> _alloc(Class isa) {
    if (isa == null) {
      isa = Class('NSObject');
    }
    NSObject result = isa.perform(Selector('alloc'));
    return result.autorelease().pointer;
  }

  static Pointer<Void> _new(Class isa) {
    if (isa == null) {
      isa = Class('NSObject');
    }
    NSObject result = isa.perform(Selector('new'));
    return result.autorelease().pointer;
  }
}
