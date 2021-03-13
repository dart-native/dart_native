import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:ffi/ffi.dart';

/// Stands for `SEL` and `@selector` in iOS.
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
    final selectorNamePtr = selectorName.toNativeUtf8();
    Pointer<Void> ptr = sel_registerName(selectorNamePtr);
    calloc.free(selectorNamePtr);
    return SEL._internal(selectorName, ptr);
  }

  factory SEL.fromPointer(Pointer<Void> ptr) {
    String selName = sel_getName(ptr).toDartString();
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
