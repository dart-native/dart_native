library dart_objc.nsobject;

import 'dart:ffi';

import 'package:dart_objc/src/common/library.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:ffi/ffi.dart';


// C header typedef:
typedef InvokeMethodC = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsC = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Utf8> selector);

// Dart header typedef
typedef InvokeMethodDart = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsDart = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Utf8> selector);

class NSObject extends Id {
  NSObject({Class isa}) {
    if (isa == null) {
      isa = Class('NSObject');
    }
    this.isa = isa;
    instance = invokeMethod(isa, 'new');
  }

  Pointer<Void> invokeMethod(Id target, String selector,
      {Pointer<Pointer<Void>> args}) {
    final selectorP = Utf8.toUtf8(selector);
    Pointer<Void> result;
    if (args != null) {
      final InvokeMethodDart nativeInvokeMethod =
          nativeRuntimeLib.lookupFunction<InvokeMethodC, InvokeMethodDart>(
              'native_instance_invoke');
      result = nativeInvokeMethod(target.instance, selectorP, args);
    } else {
      final InvokeMethodNoArgsDart nativeInvokeMethodNoArgs = nativeRuntimeLib
          .lookupFunction<InvokeMethodNoArgsC, InvokeMethodNoArgsDart>(
              'native_instance_invoke');
      result = nativeInvokeMethodNoArgs(target.instance, selectorP);
    }
    selectorP.free();
    return result;
  }
}
