import 'dart:ffi';

import 'package:dart_objc/src/common/library.dart';
import 'package:dart_objc/src/common/pointer_encoding.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:ffi/ffi.dart';

// C header typedef:
typedef MethodSignatureC = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Void> selector, Pointer<Pointer<Utf8>> typeEncodings);
typedef InvokeMethodC = Pointer<Void> Function(
    Pointer<Void> instance,
    Pointer<Void> selector,
    Pointer<Void> signature,
    Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsC = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Void> selector, Pointer<Void> signature);
typedef TypeEncodingC = Pointer<Utf8> Function(Pointer<Utf8>);

// Dart header typedef
typedef MethodSignatureDart = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Void> selector, Pointer<Pointer<Utf8>> typeEncodings);
typedef InvokeMethodDart = Pointer<Void> Function(
    Pointer<Void> instance,
    Pointer<Void> selector,
    Pointer<Void> signature,
    Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsDart = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Void> selector, Pointer<Void> signature);
typedef TypeEncodingDart = Pointer<Utf8> Function(Pointer<Utf8>);

final InvokeMethodDart nativeInvokeMethod = nativeRuntimeLib
    .lookupFunction<InvokeMethodC, InvokeMethodDart>('native_instance_invoke');
final InvokeMethodNoArgsDart nativeInvokeMethodNoArgs = nativeRuntimeLib
    .lookupFunction<InvokeMethodNoArgsC, InvokeMethodNoArgsDart>(
        'native_instance_invoke');

Pointer<Void> _msgSend(
    Pointer<Void> target, Pointer<Void> selector, Pointer<Void> signature,
    [Pointer<Pointer<Void>> args]) {
  Pointer<Void> result;
  if (args != null) {
    result = nativeInvokeMethod(target, selector, signature, args);
  } else {
    result = nativeInvokeMethodNoArgs(target, selector, signature);
  }
  return result;
}

final MethodSignatureDart nativeMethodSignature =
    nativeRuntimeLib.lookupFunction<MethodSignatureC, MethodSignatureDart>(
        'native_method_signature');
final TypeEncodingDart nativeTypeEncoding = nativeRuntimeLib
    .lookupFunction<TypeEncodingC, TypeEncodingDart>('native_type_encoding');

dynamic msgSend(id target, Selector selector, [List args]) {
  if (target == nil) {
    return null;
  }
  Pointer<Pointer<Utf8>> typeEncodingsPtrPtr =
      Pointer<Pointer<Utf8>>.allocate(count: args?.length ?? 0 + 1);
  Pointer<Void> selectorPtr = selector.toPointer();

  Pointer<Void> signature =
      nativeMethodSignature(target.pointer, selectorPtr, typeEncodingsPtrPtr);
  if (signature.address == 0) {
    throw 'signature for [$target $selector] is NULL.';
  }

  Pointer<Pointer<Void>> pointers;
  if (args != null) {
    pointers = Pointer<Pointer<Void>>.allocate(count: args.length);
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg == null) {
        // TODO: throw error.
        continue;
      }
      String typeEncodings =
          nativeTypeEncoding(typeEncodingsPtrPtr.elementAt(i + 1).load())
              .load()
              .toString();
      storeValueToPointer(arg, pointers.elementAt(i), typeEncodings);
    }
  } else if (selector.name.contains(':')) {
    //TODO: need check args count.
    throw 'Arg list not match!';
  }
  Pointer<Void> resultPtr =
      _msgSend(target.pointer, selectorPtr, signature, pointers);
  
  String typeEncodings =
      nativeTypeEncoding(typeEncodingsPtrPtr.load()).load().toString();
  typeEncodingsPtrPtr.free();
  dynamic result = loadValueFromPointer(resultPtr, typeEncodings);
  if (pointers != null) {
    pointers.free();
  }
  return result;
}
