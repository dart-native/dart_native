import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/common/interface_runtime.dart';
import 'package:ffi/ffi.dart';

class InterfaceRuntimeJava extends InterfaceRuntime {
  @override
  Future<T> invokeMethod<T>(
      Pointer<Void> nativeObjectPointer, String methodName,
      {List? args}) {
    throw UnimplementedError();
  }

  @override
  T invokeMethodSync<T>(Pointer<Void> nativeObjectPointer, String methodName,
      {List? args}) {
    // TODO: implement invokeMethodSync
    throw UnimplementedError();
  }

  @override
  Map<String, String> methodTableWithInterfaceName(String name) {
    // TODO: implement methodTableWithInterfaceName
    throw UnimplementedError();
  }

  @override
  Pointer<Void> nativeObjectPointerForInterfaceName(String name) {
    final ptr = name.toNativeUtf8();
    final result = _interfaceHostObjectWithName(ptr);
    calloc.free(ptr);
    return result;
  }

  @override
  void setMethodCallHandler(
      String interfaceName, String method, Function? function) {
    // TODO: implement setMethodCallHandler
  }
}

final Pointer<Void> Function(Pointer<Utf8>) _interfaceHostObjectWithName =
    nativeDylib
        .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
            'interfaceHostObjectWithName')
        .asFunction();
