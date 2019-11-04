import 'dart:ffi';

import 'package:dart_objc/runtime.dart';

class NSString extends NSObject {
  String value;
  NSString(this.value) : super.fromPointer(_new(value));

  NSString.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    value = perform(Selector('UTF8String'));
  }

  bool operator ==(other) {
    if (other == null) return false;
    if (other == nil) return false;
    if (other is String) return value == other;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
  }
}

Pointer<Void> _new(String value) {
  NSObject result = Class('NSString').perform(Selector('stringWithUTF8String:'), args: [value]);
  return result.pointer;
}