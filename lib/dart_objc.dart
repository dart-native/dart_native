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
  final Pointer<Utf8> strPtr = Utf8.toUtf8('test_str:%@');
  final Pointer<Pointer<Utf8>> strPtrPtr = Pointer<Pointer<Utf8>>.allocate();
  strPtrPtr.store(strPtr);
  Pointer<Void> str = invokeMethod(getClass('NSString'), 'stringWithUTF8String:', args: strPtrPtr.cast());
  // final Pointer<Pointer> args = Pointer<Pointer>.allocate(count: 2);
  // args.elementAt(0).store(str);
  // Pointer<Void> object = invokeMethod(getClass('NSObject'), 'new');
  // args.elementAt(1).store(object);
  // Pointer<Void> result = invokeMethod(getClass('NSString'), 'stringWithFormat:', args: args.cast());
  Pointer<Void> stub = invokeMethod(getClass('RuntimeStub'), 'new');
  // final Pointer<Int8> arg = Pointer<Int8>.allocate();
  // arg.store(123);
  // final Pointer<Pointer<Int8>> result = Pointer<Pointer<Int8>>.allocate();
  // result.store(arg);
  // invokeMethod(stub, 'foo:', args: Pointer<Pointer>.allocate()..store(result)..cast());
  Pointer<Pointer<Void>> argsPtrPtr = Pointer<Pointer<Void>>.allocate()..store(str);
  invokeMethod(stub, 'foo:', args: argsPtrPtr);
}
