import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

typedef Pointer<Void> InitSubclass(dynamic value, String clsName);

/// Dart Wrapper for subclass of JObject. For example: JString, JArray, Integer, etc.
class JSubclass<T> extends JObject {
  T raw;

  JSubclass(this.raw, InitSubclass init, String clsName) : super(clsName, pointer: init(raw, clsName));
  JSubclass.fromPointer(Pointer<Void> ptr, String clsName) : super(clsName, pointer: ptr);

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
