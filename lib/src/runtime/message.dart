import 'dart:ffi';

import 'package:dart_objc/src/common/library.dart';
import 'package:dart_objc/src/common/native_type_encoding.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:ffi/ffi.dart';

// C header typedef:
typedef InvokeMethodC = Pointer<Void> Function(
    Pointer<Void> instance,
    Pointer<Utf8> selector,
    Pointer<Pointer<Utf8>> returnType,
    Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsC = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Utf8>> returnType);
typedef TypeEncodingC = Pointer<Utf8> Function(Pointer<Utf8>);

// Dart header typedef
typedef InvokeMethodDart = Pointer<Void> Function(
    Pointer<Void> instance,
    Pointer<Utf8> selector,
    Pointer<Pointer<Utf8>> returnType,
    Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsDart = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Utf8>> returnType);
typedef TypeEncodingDart = Pointer<Utf8> Function(Pointer<Utf8>);

Pointer<Void> _msgSend(
    Pointer<Void> target, String selector, Pointer<Pointer<Utf8>> returnType,
    [Pointer<Pointer<Void>> args]) {
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

dynamic msgSend(id target, Selector selector, [List args]) {
  Pointer<Pointer<Void>> pointers;
  if (args != null) {
    pointers = Pointer<Pointer<Void>>.allocate(count: args.length);
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg is Pointer) {
        pointers.elementAt(i).store(arg);
      } else if (arg is id) {
        pointers.elementAt(i).store(arg.pointer);
      }
      // TODO: convert Dart type to native.
    }
  }

  Pointer<Pointer<Utf8>> returnTypePtrPtr = Pointer<Pointer<Utf8>>.allocate();
  Pointer<Void> resultPtr =
      _msgSend(target.pointer, selector.name, returnTypePtrPtr, pointers);
  final TypeEncodingDart nativeTypeEncoding = nativeRuntimeLib
      .lookupFunction<TypeEncodingC, TypeEncodingDart>('native_type_encoding');
  String returnType =
      nativeTypeEncoding(returnTypePtrPtr.load()).load().toString();
  returnTypePtrPtr.free();
  dynamic result = nativeValueForEncoding(resultPtr, returnType);
  if (pointers != null) {
    pointers.free();
  }
  return result;
}
