import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';
import 'package:dart_native/src/common/interface_runtime.dart';
import 'package:ffi/ffi.dart';

class InterfaceRuntimeJava extends InterfaceRuntime {
  @override
  Future<T> invokeMethod<T>(
      Pointer<Void> nativeObjectPointer, String method, String methodSignature,
      {List? args}) {
    List<String> sigList = methodSignature.split('\'');
    if (sigList.isEmpty) {
      throw 'invokeMethodSync error can not get method signature of $method';
    }
    return invoke(nativeObjectPointer, method, sigList[0],
            args: args,
            assignedSignature: sigList.sublist(1),
            isInterface: true)
        .then((reslut) {
      return reslut;
    });
  }

  @override
  T invokeMethodSync<T>(
      Pointer<Void> nativeObjectPointer, String method, String methodSignature,
      {List? args}) {
    List<String> sigList = methodSignature.split('\'');
    if (sigList.isEmpty) {
      throw 'invokeMethodSync error can not get method signature of $method';
    }
    return invokeSync(nativeObjectPointer, method, sigList[0],
        args: args, assignedSignature: sigList.sublist(1), isInterface: true);
  }

  @override
  Map<String, String> methodTableWithInterfaceName(String name) {
    return _mapForInterfaceMetaData(name);
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

final Pointer<Void> Function(Pointer<Utf8>) _interfaceAllMetaData = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'interfaceAllMetaData')
    .asFunction();

Map<String, String> _mapForInterfaceMetaData(String interfaceName) {
  final namePtr = interfaceName.toNativeUtf8();
  Pointer<Void> ptr = _interfaceAllMetaData(namePtr);
  calloc.free(namePtr);

  String? signaturesStr = fromUtf16(ptr);
  if (signaturesStr == null ||
      signaturesStr.isEmpty ||
      signaturesStr.length == 2) {
    return {};
  }

  // remove '{' and '}'
  String templeStr = signaturesStr.substring(1, signaturesStr.length - 1);
  List<String> signatures = templeStr.split(', ');
  Map<String, String> signatureMap = {};
  for (var siganture in signatures) {
    List<String> methodInfo = siganture.split('=');
    if (methodInfo.length != 2) {
      throw '\'$interfaceName\' get method signature error, siganture = \'$siganture\'';
    }
    // key is method name, vlaue is method signature
    signatureMap[methodInfo[0]] = methodInfo[1];
  }

  return signatureMap;
}
