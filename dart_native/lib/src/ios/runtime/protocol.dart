import 'dart:ffi';

import 'package:dart_native/src/ios/common/callback_register.dart';
import 'package:dart_native/src/ios/runtime/functions.dart';
import 'package:dart_native/src/ios/runtime/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
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
    free(protocolNamePtr);
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

abstract class BasicProtocol {
  register();
}

/// Register callback function for selector in protocol.
/// Protocol [protocolType] must be used in native code.
bool registerProtocolCallback(
    dynamic target, Function callback, String selName, Type protocolType) {
  String protoName = protocolType.toString();
  SEL selector = SEL(selName);
  Protocol protocol = Protocol(protoName);
  if (protocol == null) {
    // FIXME: Use Dart Function signature to create a native method.
    throw 'Protocol($protoName) never used in native code! Can not get Protocol by its name!';
  }
  Pointer<Utf8> types =
      nativeProtocolMethodTypes(protocol.toPointer(), selector.toPointer());
  return registerMethodCallback(target, selector, callback, types);
}
