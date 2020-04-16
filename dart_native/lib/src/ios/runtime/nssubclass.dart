import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/nsobject.dart';

typedef Pointer<Void> InitSubclass(dynamic value);

/// Dart Wrapper for subclass of NSObject. For example: NSString, NSArray, etc.
class NSSubclass<T> extends NSObject {
  T value;

  NSSubclass(this.value, InitSubclass init) : super.fromPointer(init(value));
  NSSubclass.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  bool operator ==(other) {
    if (other == null) return false;
    if (other == nil) return false;
    if (other is T) return value == other;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
  }
}
