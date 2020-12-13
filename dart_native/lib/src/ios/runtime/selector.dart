import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:ffi/ffi.dart';

/// Stands for `SEL` in Objective-C.
///
/// An opaque type that represents a method selector.
class SEL {
  String name;
  Pointer<Void> _selPtr;

  static final Map<String, SEL> _cache = <String, SEL>{};

  factory SEL(String selectorName) {
    if (selectorName == null) {
      return null;
    }
    if (_cache.containsKey(selectorName)) {
      return _cache[selectorName];
    }
    final selectorNamePtr = Utf8.toUtf8(selectorName);
    Pointer<Void> ptr = sel_registerName(selectorNamePtr);
    free(selectorNamePtr);
    return SEL._internal(selectorName, ptr);
  }

  factory SEL.fromPointer(Pointer<Void> ptr) {
    String selName = Utf8.fromUtf8(sel_getName(ptr));
    if (_cache.containsKey(selName)) {
      return _cache[selName];
    } else {
      return SEL._internal(selName, ptr);
    }
  }

  SEL._internal(this.name, this._selPtr) {
    _cache[this.name] = this;
  }

  Pointer<Void> toPointer() {
    return _selPtr;
  }

  bool operator ==(other) {
    if (other == null) return false;
    return _selPtr == other._selPtr;
  }

  int get hashCode {
    return _selPtr.hashCode;
  }

  @override
  String toString() {
    return name;
  }
}

SEL selector(String s) => SEL(s);

extension ToSEL on String {
  SEL toSEL() => SEL(this);
}
