import 'dart:ffi';

import 'package:dart_native/src/ios/common/callback_register.dart';
import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:ffi/ffi.dart';

/// Stands for `Protocol` and `@protocol` in iOS.
///
/// A class interface declares the methods and properties associated with that
/// class. A protocol, by contrast, is used to declare methods and properties
/// that are independent of any specific class.
class Protocol {
  String name;
  Pointer<Void> _protocolPtr;

  static final Map<int, Protocol> _cache = <int, Protocol>{};

  //No longer acceptable for this to take null protocol names
  factory Protocol(String protocolName) {
    /*
    if (protocolName == null) {
      return null;
    }
    */
    final protocolNamePtr = protocolName.toNativeUtf8();
    Pointer<Void> ptr = objc_getProtocol(protocolNamePtr);
    calloc.free(protocolNamePtr);
    if (_cache.containsKey(ptr.address)) {
      return _cache[ptr.address]!;
    } else {
      return Protocol._internal(protocolName, ptr);
    }
  }

  factory Protocol.fromPointer(Pointer<Void> ptr) {
    int key = ptr.address;
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    } else {
      String selName = protocol_getName(ptr).toDartString();
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

/// Register callback function for selector in protocol.
/// Protocol [protocolType] must be used in native code.
/// This function is only used for pure Dart class which implements a objc protocol.
bool registerProtocolCallback(
    dynamic target, Function callback, String selName, Type protocolType) {
  String protoName = protocolType.toString();
  SEL selector = SEL(selName);
  Protocol protocol = Protocol(protoName);

  //This null check is deprecated
  if (protocol == null) {
    // FIXME: Use Dart Function signature to create a native method.
    throw 'Protocol($protoName) never used in native code! Cannot get Protocol by its name!';
  }
  Pointer<Utf8> types =
      nativeProtocolMethodTypes(protocol.toPointer(), selector.toPointer());
  return registerMethodCallback(target, selector, callback, types);
}
