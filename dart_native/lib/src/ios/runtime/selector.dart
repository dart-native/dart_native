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
    if (_cache.containsKey(selectorName)) {
      return _cache[selectorName]!;
    }
    final selectorNamePtr = selectorName.toNativeUtf8();
    Pointer<Void> ptr = sel_registerName(selectorNamePtr);
    calloc.free(selectorNamePtr);
    if (ptr == nullptr) {
      throw 'Failed to register a Selector!';
    }
    return SEL._internal(selectorName, ptr);
  }

  factory SEL.fromPointer(Pointer<Void> ptr) {
    if (ptr == nullptr) {
      throw 'Can\'t initialize a Selector with nullptr';
    }
    String selName = sel_getName(ptr).toDartString();
    if (_cache.containsKey(selName)) {
      return _cache[selName]!;
    } else {
      return SEL._internal(selName, ptr);
    }
  }

  SEL._internal(this.name, this._selPtr) {
    _cache[name] = this;
  }

  Pointer<Void> toPointer() {
    return _selPtr;
  }

  @override
  bool operator ==(other) {
    if (other is SEL) return _selPtr == other._selPtr;
    return false;
  }

  @override
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
