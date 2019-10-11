import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_objc/src/common/library.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

// C header typedef:
typedef InvokeMethodC = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Utf8>> returnType, Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsC = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Utf8> selector, Pointer<Pointer<Utf8>> returnType);
typedef TypeEncodingC = Pointer<Utf8> Function(Pointer<Utf8>);

// Dart header typedef
typedef InvokeMethodDart = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Utf8>> returnType, Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsDart = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Utf8> selector, Pointer<Pointer<Utf8>> returnType);
typedef TypeEncodingDart = Pointer<Utf8> Function(Pointer<Utf8>);

class NSObject extends id {
  NSObject({Class isa}) {
    if (isa == null) {
      isa = Class('NSObject');
    }
    this.isa = isa;
    Pointer<Pointer<Utf8>> returnType =  Pointer<Pointer<Utf8>>.allocate();
    internalPtr = _invokeMethod(isa.internalPtr, 'new', returnType);
    returnType.free();
  }

  dynamic performSelector(String selector, List args) {
    Pointer<Pointer<Void>> pointers = Pointer<Pointer<Void>>.allocate(count: args.length);
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg is Pointer) {
        pointers.elementAt(i).store(arg);
      }
      else if (arg is id) {
        pointers.elementAt(i).store(arg.internalPtr);
      }
      // TODO: convert Dart type to native.
    }
    Pointer<Pointer<Utf8>> returnTypePtrPtr =  Pointer<Pointer<Utf8>>.allocate();
    Pointer<Void> resultPtr = _invokeMethod(this.internalPtr, selector, returnTypePtrPtr, args: pointers);
    final TypeEncodingDart nativeTypeEncoding =
        nativeRuntimeLib.lookupFunction<TypeEncodingC, TypeEncodingDart>(
            'native_type_encoding');
    String returnType = nativeTypeEncoding(returnTypePtrPtr.load()).load().toString();
    returnTypePtrPtr.free();
    dynamic result = _nativeValueForEncoding(resultPtr, returnType);
    pointers.free();
    return result;
  }
}

dynamic _nativeValueForEncoding(Pointer<Void> ptr, String encoding) {
  // TODO: convert return value to Dart type.
  dynamic result;
  switch (encoding) {
    case 'int':
      result = ptr.address;
      break;
    case 'float':
      ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
      result = ByteData.view(buffer).getFloat32(0, Endian.host);
      break;
    case 'double':
      ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
      result = ByteData.view(buffer).getFloat64(0, Endian.host);
      break;
    case 'pointer':
      result = ptr;
      break;
    default:
  }
}

Pointer<Void> _invokeMethod(Pointer<Void> target, String selector, Pointer<Pointer<Utf8>> returnType,
    {Pointer<Pointer<Void>> args}) {
  final selectorP = Utf8.toUtf8(selector);
  Pointer<Void> result;
  if (args != null) {
    final InvokeMethodDart nativeInvokeMethod =
        nativeRuntimeLib.lookupFunction<InvokeMethodC, InvokeMethodDart>(
            'native_instance_invoke');
    result = nativeInvokeMethod(target, selectorP, returnType, args);
  } else {
    final InvokeMethodNoArgsDart nativeInvokeMethodNoArgs = nativeRuntimeLib
        .lookupFunction<InvokeMethodNoArgsC, InvokeMethodNoArgsDart>(
            'native_instance_invoke');
    result = nativeInvokeMethodNoArgs(target, selectorP, returnType);
  }
  selectorP.free();
  return result;
}
