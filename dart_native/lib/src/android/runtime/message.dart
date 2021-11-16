import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/dart_java.dart';
import 'package:dart_native/src/android/runtime/functions.dart';

Pointer<Void> _newNativeObject(String className, {List? args}) {
  final objectPtr;
  Pointer<Utf8> classNamePtr = className.toNativeUtf8();
  if (args == null || args.length == 0) {
    objectPtr =
        nativeCreateObject!(classNamePtr, nullptr.cast(), nullptr.cast(), 0, 0);
  } else {
    NativeArguments nativeArguments = _parseNativeArguments(args);
    objectPtr = nativeCreateObject!(
        classNamePtr,
        nativeArguments.pointers,
        nativeArguments.typePointers,
        args.length,
        nativeArguments.stringTypeBitmask);
    nativeArguments.freePointers();
  }
  calloc.free(classNamePtr);
  return objectPtr;
}

Pointer<Void> newObject(String className, JObject object,
    {Pointer<Void>? pointer, List? args, bool isInterface = false}) {
  if (isInterface) {
    Pointer<Int64> hashPointer = calloc<Int64>();
    hashPointer.value = identityHashCode(object);
    return hashPointer.cast<Void>();
  }

  if (pointer == null) {
    return _newNativeObject(className);
  }
  return pointer;
}

typedef void _AsyncMessageCallback(dynamic result);
Map<Pointer<Utf8>, _AsyncMessageCallback> _invokeCallbackMap = Map();
Pointer<NativeFunction<InvokeCallback>> _invokeCallbackPtr =
    Pointer.fromFunction(_invokeCallback);

void _invokeCallback(
    Pointer<Void> result, Pointer<Utf8> method, Pointer<Utf8> returnType) {
  final callback = _invokeCallbackMap[method];
  if (callback != null) {
    dynamic value = loadValueFromPointer(result, returnType.toDartString());
    callback(value);
    _invokeCallbackMap.remove(method);
  }
  calloc.free(method);
  calloc.free(returnType);
}

dynamic _invokeMethod(
    Pointer<Void> objPtr, String methodName, List? args, String returnType,
    {List? argsSignature, _AsyncMessageCallback? callback}) {
  Pointer<Utf8> methodNamePtr = methodName.toNativeUtf8();
  Pointer<Utf8> returnTypePtr = returnType.toNativeUtf8();

  Pointer<NativeFunction<InvokeCallback>> callbackPtr = nullptr.cast();
  if (callback != null) {
    _invokeCallbackMap[methodNamePtr] = callback;
    callbackPtr = _invokeCallbackPtr;
  }

  NativeArguments nativeArguments =
      _parseNativeArguments(args, argsSignature: argsSignature);

  Pointer<Void> invokeMethodRet = nativeInvoke!(
      objPtr,
      methodNamePtr,
      nativeArguments.pointers,
      nativeArguments.typePointers,
      args?.length ?? 0,
      returnTypePtr,
      nativeArguments.stringTypeBitmask,
      callbackPtr);

  dynamic result;
  if (callback == null) {
    result = loadValueFromPointer(
        invokeMethodRet,
        nativeArguments.typePointers
            .elementAt(args?.length ?? 0)
            .value
            .toDartString());

    nativeArguments.freePointers();
    calloc.free(methodNamePtr);
    calloc.free(returnTypePtr);
  }
  return result;
}

dynamic invokeMethod(
    Pointer<Void> objPtr, String methodName, List? args, String returnType,
    {List? argsSignature}) {
  return _invokeMethod(objPtr, methodName, args, returnType,
      argsSignature: argsSignature);
}

Future<dynamic> invokeMethodAsync(
    Pointer<Void> objPtr, String methodName, List? args, String returnType,
    {List? argsSignature}) async {
  final completer = Completer<dynamic>();
  _invokeMethod(objPtr, methodName, args, returnType,
      argsSignature: argsSignature, callback: (dynamic result) {
    completer.complete(result);
  });
  return completer.future;
}

NativeArguments _parseNativeArguments(List? args, {List? argsSignature}) {
  Pointer<Pointer<Void>> pointers = nullptr.cast();
  Pointer<Pointer<Utf8>> typePointers =
      calloc<Pointer<Utf8>>((args?.length ?? 0) + 1);

  /// extend for string
  int stringTypeBitmask = 0;
  if (args != null && args.length > 0) {
    int length = args.length;

    /// for 32 bit system
    if (!is64Bit) {
      args.forEach((arg) {
        if (arg is double || arg is long) {
          length++;
        }
      });
    }
    pointers = calloc<Pointer<Void>>(length);

    for (var i = 0, pi = 0; i < args.length; i++, pi++) {
      var arg = args[i];
      if (arg == null) {
        throw 'One of args list is null';
      }

      /// check extension signature
      Pointer<Utf8>? signature;
      if (argsSignature != null) {
        if (argsSignature[i] is String) {
          signature = argsSignature[i].toNativeUtf8();
        } else if (argsSignature[i] is Pointer<Utf8>) {
          signature = argsSignature[i];
        }
      }

      /// check string
      if (arg is String) {
        stringTypeBitmask |= (0x1 << i);
      }

      storeValueToPointer(
          arg, pointers.elementAt(pi), typePointers.elementAt(i), signature);

      /// check 32 bit system
      if (!is64Bit && (arg is double || arg is long)) {
        pi++;
      }
    }
  }
  typePointers.elementAt(args?.length ?? 0).value = "0".toNativeUtf8();
  return NativeArguments(pointers, typePointers, stringTypeBitmask);
}

class NativeArguments {
  final Pointer<Pointer<Void>> pointers;
  final Pointer<Pointer<Utf8>> typePointers;
  int stringTypeBitmask;

  NativeArguments(this.pointers, this.typePointers, this.stringTypeBitmask);

  void freePointers() {
    calloc.free(pointers);
    calloc.free(typePointers);
  }
}
