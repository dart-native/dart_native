import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/nsobject.dart';

typedef Pointer<Void> InitSubclass(dynamic value);

/// Dart Wrapper for subclass of NSObject. For example: NSString, NSArray, etc.
class NSSubclass<T> extends NSObject {
  T raw;

  NSSubclass(this.raw, InitSubclass init) : super.fromPointer(init(raw));
  NSSubclass.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  bool operator ==(other) {
    if (other == nil) {
      return false;
    }
    if (other is T) {
      return raw == other;
    }
    return raw == other.raw;
  }

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() {
    return raw.toString();
  }
}
