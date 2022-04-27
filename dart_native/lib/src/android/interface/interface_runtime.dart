import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/runtime/call_back.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';
import 'package:dart_native/src/common/interface_runtime.dart';
import 'package:ffi/ffi.dart';

/// The mappings of interface method handler
Map<String, Map<String, Function?>> _methodHandlerCache = {};

class InterfaceRuntimeJava extends InterfaceRuntime {
  final isInitSuccess = initDartAPISuccess;

  @override
  Future<T> invokeMethod<T>(Pointer<Void> nativeObjectPointer, String method,
      {List? args}) {
    List<String> methodInfo = method.split(':');
    if (methodInfo.length != 2) {
      throw 'invokeMethod error can not get method info of $method';
    }
    List<String> sigList = methodInfo[1].split('\'');
    if (sigList.isEmpty) {
      throw 'invokeMethod error can not get method signature of $method';
    }
    return invoke(nativeObjectPointer, methodInfo[0], sigList[0],
            args: args,
            assignedSignature: sigList.sublist(1),
            isInterface: true)
        .then((reslut) {
      return reslut;
    });
  }

  @override
  T invokeMethodSync<T>(Pointer<Void> nativeObjectPointer, String method,
      {List? args}) {
    List<String> methodInfo = method.split(':');
    if (methodInfo.length != 2) {
      throw 'invokeMethod error can not get method info of $method';
    }
    List<String> sigList = methodInfo[1].split('\'');
    if (sigList.isEmpty) {
      throw 'invokeMethodSync error can not get method signature of $method';
    }
    return invokeSync(nativeObjectPointer, methodInfo[0], sigList[0],
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
    Map<String, Function?>? methodsMap = _methodHandlerCache[interfaceName];
    if (methodsMap == null) {
      methodsMap = {method: function};
    } else {
      methodsMap[method] = function;
    }
    _methodHandlerCache[interfaceName] = methodsMap;
    final namePtr = interfaceName.toNativeUtf8();
    final methodPtr = method.toNativeUtf8();
    String typeString = function.runtimeType.toString();
    List<String> functionSignature = typeString.split(' => ');
    bool shouldReturnAsync = functionSignature.length == 2 &&
        functionSignature[1].startsWith('Future');
    _registerDartInterface(namePtr, methodPtr, _interfaceInvokeDart, nativePort,
        shouldReturnAsync ? 1 : 0);
    calloc.free(namePtr);
    calloc.free(methodPtr);
  }
}

final Pointer<Void> Function(Pointer<Utf8>) _interfaceHostObjectWithName =
    nativeDylib
        .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
            'InterfaceHostObjectWithName')
        .asFunction();

final Pointer<Void> Function(Pointer<Utf8>) _interfaceAllMetaData = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'InterfaceAllMetaData')
    .asFunction();

final void Function(Pointer<Utf8>, Pointer<Utf8>,
        Pointer<NativeFunction<MethodNativeCallback>>, int, int)
    _registerDartInterface = nativeDylib
        .lookup<
            NativeFunction<
                Void Function(
                    Pointer<Utf8>,
                    Pointer<Utf8>,
                    Pointer<NativeFunction<MethodNativeCallback>>,
                    Int64,
                    Int32)>>('InterfaceRegisterDartInterface')
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

  /// remove '{' and '}'
  String templeStr = signaturesStr.substring(1, signaturesStr.length - 1);
  List<String> signatures = templeStr.split(', ');
  Map<String, String> signatureMap = {};
  for (var siganture in signatures) {
    List<String> methodInfo = siganture.split('=');
    if (methodInfo.length != 2) {
      throw '\'$interfaceName\' get method signature error, siganture = \'$siganture\'';
    }

    /// key is interface method name, value is java method signature
    signatureMap[methodInfo[0]] = methodInfo[1];
  }

  return signatureMap;
}

Pointer<NativeFunction<MethodNativeCallback>> _interfaceInvokeDart =
    Pointer.fromFunction(_invokeDart);

void _invokeDart(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    int argCount,
    int shouldReturnAsync) {
  String interfaceName = targetPtr.cast<Utf8>().toDartString();
  String functionName = funNamePtr.cast<Utf8>().toDartString();
  Map<String, Function?>? method = _methodHandlerCache[interfaceName];
  Function? function = method?[functionName];
  if (function == null) {
    argsPtrPtr.elementAt(argCount).value = nullptr.cast();
    return;
  }
  jniInvokeDart(function, argsPtrPtr, argTypesPtrPtr, argCount,
      shouldReturnAsync: shouldReturnAsync == 1);
}
