import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:ffi/ffi.dart';

class Selector {
  String name;
  Pointer<Void> _selPtr;

  static final Map<int, Selector> _cache = <int, Selector>{};

  factory Selector(String selectorName) {
    if (selectorName == null) {
      return null;
    }
    final selectorNamePtr = Utf8.toUtf8(selectorName);
    Pointer<Void> ptr = sel_registerName(selectorNamePtr);
    selectorNamePtr.free();
    if (_cache.containsKey(ptr.address)) {
      return _cache[ptr.address];
    } else {
      return Selector._internal(selectorName, ptr);
    }
  }

  factory Selector.fromPointer(Pointer<Void> ptr) {
    int key = ptr.address;
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      String selName = Utf8.fromUtf8(sel_getName(ptr));
      return Selector._internal(selName, ptr);
    }
  }

  Selector._internal(this.name, this._selPtr) {
    _cache[_selPtr.address] = this;
  }

  Pointer<Void> toPointer() {
    return _selPtr;
  }

  @override
  String toString() {
    return name;
  }
}

class SEL extends Selector {
  factory SEL(String selectorName) => Selector(selectorName);
  factory SEL.fromPointer(Pointer<Void> ptr) => Selector.fromPointer(ptr);
}