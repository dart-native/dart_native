import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:ffi/ffi.dart';

import 'jclass.dart';

void passJObjectToNative(JObject obj) {
  if (initDartAPISuccess && obj != null) {
    passJObjectToC(obj, obj.pointer);
  } else {
    print('pass object to native failed! address=${obj?.pointer}');
  }
}

class JObject extends JClass {
  Pointer _ptr;

  //init target class
  JObject(String className, {Pointer pointer, bool isInterface = false})
      : super(className) {
    if (isInterface) {
      Pointer<Int64> hashPointer = allocate();
      hashPointer.value = identityHashCode(this);
      _ptr = hashPointer.cast<Void>();
      return;
    }

    if (pointer == null) {
      Pointer<Utf8> classNamePtr = Utf8.toUtf8(super.className);
      pointer = nativeCreateClass(classNamePtr, nullptr, nullptr, 0, 0);
      free(classNamePtr);
    }

    _ptr = pointer;
    passJObjectToNative(this);
  }

  JObject.parameterConstructor(String clsName, List args) : super(clsName) {
    NativeArguments nativeArguments = _parseNativeArguments(args);
    Pointer<Utf8> classNamePtr = Utf8.toUtf8(super.className);
    _ptr = nativeCreateClass(
        classNamePtr,
        nativeArguments.pointers,
        nativeArguments.typePointers,
        args?.length ?? 0,
        nativeArguments.stringTypeBitmask);
    free(classNamePtr);
    passJObjectToNative(this);
    nativeArguments.freePointers();
  }

  Pointer get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List args, String returnType,
      {List argsSignature}) {
    Pointer<Utf8> methodNamePtr = Utf8.toUtf8(methodName);
    Pointer<Utf8> returnTypePtr = Utf8.toUtf8(returnType);

    NativeArguments nativeArguments =
        _parseNativeArguments(args, argsSignature: argsSignature);
    Pointer<Void> invokeMethodRet = nativeInvoke(
        _ptr,
        methodNamePtr,
        nativeArguments.pointers,
        nativeArguments.typePointers,
        args?.length ?? 0,
        returnTypePtr,
        nativeArguments.stringTypeBitmask);

    dynamic result = loadValueFromPointer(invokeMethodRet, returnType,
        typePtr: nativeArguments.typePointers.elementAt(args?.length ?? 0));

    nativeArguments.freePointers();
    free(methodNamePtr);
    free(returnTypePtr);
    return result;
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }

  NativeArguments _parseNativeArguments(List args, {List argsSignature}) {
    Pointer<Pointer<Void>> pointers = nullptr.cast();

    /// extend a bit for string
    Pointer<Pointer<Utf8>> typePointers =
        allocate<Pointer<Utf8>>(count: (args?.length ?? 0) + 1);
    int stringTypeBitmask = 0;
    if (args != null) {
      pointers = allocate<Pointer<Void>>(count: args.length);

      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }

        Pointer<Utf8> argSignature =
            argsSignature == null || !(argsSignature[i] is Pointer<Utf8>)
                ? null
                : argsSignature[i];

        if (arg is String) {
          stringTypeBitmask |= (0x1 << i);
        }

        storeValueToPointer(arg, pointers.elementAt(i),
            typePtr: typePointers.elementAt(i), argSignature: argSignature);
      }
    }
    typePointers.elementAt(args?.length ?? 0).value = Utf8.toUtf8("0");
    return NativeArguments(pointers, typePointers, stringTypeBitmask);
  }
}

class NativeArguments {
  final Pointer<Pointer<Void>> pointers;
  final Pointer<Pointer<Utf8>> typePointers;
  int stringTypeBitmask;

  NativeArguments(this.pointers, this.typePointers, this.stringTypeBitmask);

  void freePointers() {
    free(pointers);
    free(typePointers);
  }
}
