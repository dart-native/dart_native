import 'dart:ffi';

import 'package:dart_objc/src/runtime/functions.dart';
import 'package:ffi/ffi.dart';

class Protocol {
  String name;
  Pointer<Void> _protocolPtr;

  static final Map<int, Protocol> _cache = <int, Protocol>{};

  factory Protocol(String protocolName) {
    if (protocolName == null) {
      return null;
    }
    final protocolNamePtr = Utf8.toUtf8(protocolName);
    Pointer<Void> ptr = objc_getProtocol(protocolNamePtr);
    protocolNamePtr.free();
    if (_cache.containsKey(ptr.address)) {
      return _cache[ptr.address];
    } else {
      return Protocol._internal(protocolName, ptr);
    }
  }

  factory Protocol.fromPointer(Pointer<Void> ptr) {
    int key = ptr.address;
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      String selName = Utf8.fromUtf8(protocol_getName(ptr));
      return Protocol._internal(selName, ptr);
    }
  }

  Protocol._internal(this.name, this._protocolPtr) {
    _cache[_protocolPtr.address] = this;
  }

  Pointer<Void> toPointer() {
    return _protocolPtr;
  }

  @override
  String toString() {
    return name;
  }
}

extension ToProtocol on String {
  Protocol toProtocol() => Protocol(this);
}