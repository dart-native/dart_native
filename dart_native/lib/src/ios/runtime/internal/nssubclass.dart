import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/nsobject.dart';

typedef InitSubclass = Pointer<Void> Function(dynamic value);

/// Dart Wrapper for subclass of NSObject. For example: NSString, NSArray, etc.
class NSSubclass<T> extends NSObject {
  late T raw;

  NSSubclass(this.raw, InitSubclass init) : super.fromPointer(init(raw));
  NSSubclass.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  @override
  bool operator ==(other) {
    if (other == nil) {
      return false;
    }
    if (other is T) {
      return raw == other;
    }
    if (other is NSSubclass) return raw == other.raw;
    return false;
  }

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() {
    return raw.toString();
  }
}
