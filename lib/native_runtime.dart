import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

final DynamicLibrary nativeRuntimeLib = Platform.isAndroid
    ? DynamicLibrary.open('libnative_runtime.so')
    : DynamicLibrary.open('native_runtime.framework/native_runtime');
final DynamicLibrary nativeLib = DynamicLibrary.process();

// C header typedef:
typedef MethodIMPC = Pointer<NativeFunction<IMPC>> Function(
    Pointer<Utf8> cls, Pointer<Utf8> selector, Int32 isMethodClass);
typedef InvokeMethodC = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Utf8> selector);
// id (*IMP)(id, SEL, ...)
typedef IMPC = Pointer<Void> Function(Pointer<Void>, Pointer<Utf8> sel);

// Dart header typedef
typedef MethodIMPDart = Pointer<NativeFunction<IMPC>> Function(
    Pointer<Utf8> cls, Pointer<Utf8> selector, int isMethodClass);
typedef InvokeMethodDart = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Utf8> selector);
typedef IMPDart = Pointer<Void> Function(Pointer<Void>, Pointer<Utf8> sel);

IMPDart getMethodIMP(String cls, String selector, bool isClassMethod) {
  final MethodIMPDart nativeRuntimeInvoke = nativeRuntimeLib
      .lookupFunction<MethodIMPC, MethodIMPDart>('native_method_imp');
  final clsP = Utf8.toUtf8(cls);
  final selectorP = Utf8.toUtf8(selector);
  Pointer<NativeFunction<IMPC>> imp =
      nativeRuntimeInvoke(clsP, selectorP, isClassMethod ? 1 : 0);
  IMPDart function = imp.asFunction<IMPDart>();
  clsP.free();
  selectorP.free();
  return function;
}

Pointer<Void> getClass(String className) {
  final Pointer<Void> Function(Pointer<Utf8>) nativeGetClass = nativeLib
      .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
          'objc_getClass')
      .asFunction();
  final classNameP = Utf8.toUtf8(className);
  Pointer<Void> result = nativeGetClass(classNameP);
  classNameP.free();
  return result;
}

Pointer<Void> invokeMethod(Pointer<Void> target, String selector, {List args}) {
  final InvokeMethodDart nativeInvokeMethod =
      nativeRuntimeLib.lookupFunction<InvokeMethodC, InvokeMethodDart>(
          'native_instance_invoke');
  final selectorP = Utf8.toUtf8(selector);
  Pointer<Void> result = nativeInvokeMethod(target, selectorP);
  selectorP.free();
  return result;
}

// test
void invoke() {
  Pointer<Void> object = invokeMethod(getClass('RuntimeStub'), 'new');
  invokeMethod(object, 'foo:', args: [1]);
}