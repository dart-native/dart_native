import 'dart:ffi';
import 'package:ffi/ffi.dart';

final DynamicLibrary nativeRuntimeLib = DynamicLibrary.open('dart_objc.framework/dart_objc');
final DynamicLibrary nativeLib = DynamicLibrary.process();

// C header typedef:
typedef MethodIMPC = Pointer<NativeFunction<IMPC>> Function(
    Pointer<Utf8> cls, Pointer<Utf8> selector, Int32 isMethodClass);
typedef InvokeMethodC = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsC = Pointer<Void> Function(
    Pointer<Void> instance, Pointer<Utf8> selector);
// id (*IMP)(id, SEL, ...)
typedef IMPC = Pointer<Void> Function(Pointer<Void>, Pointer<Utf8> sel);

// Dart header typedef
typedef MethodIMPDart = Pointer<NativeFunction<IMPC>> Function(
    Pointer<Utf8> cls, Pointer<Utf8> selector, int isMethodClass);
typedef InvokeMethodDart = Pointer<Void> Function(Pointer<Void> instance,
    Pointer<Utf8> selector, Pointer<Pointer<Void>> args);
typedef InvokeMethodNoArgsDart = Pointer<Void> Function(
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

Pointer<Void> invokeMethod(Pointer<Void> target, String selector,
    {Pointer<Pointer<Void>> args}) {
  final selectorP = Utf8.toUtf8(selector);
  Pointer<Void> result;
  if (args != null) {
    final InvokeMethodDart nativeInvokeMethod =
        nativeRuntimeLib.lookupFunction<InvokeMethodC, InvokeMethodDart>(
            'native_instance_invoke');
    result = nativeInvokeMethod(target, selectorP, args);
  } else {
    final InvokeMethodNoArgsDart nativeInvokeMethodNoArgs = nativeRuntimeLib
        .lookupFunction<InvokeMethodNoArgsC, InvokeMethodNoArgsDart>(
            'native_instance_invoke');
    result = nativeInvokeMethodNoArgs(target, selectorP);
  }
  selectorP.free();
  return result;
}

// test
void invoke() {
  Pointer<Void> object = invokeMethod(getClass('RuntimeStub'), 'new');
  final Pointer<Int8> arg = Pointer<Int8>.allocate();
  arg.store(123);
  final Pointer<IntPtr> result = Pointer<IntPtr>.allocate();
  result.store(arg.address);
  invokeMethod(object, 'foo:', args: result.cast());
}
