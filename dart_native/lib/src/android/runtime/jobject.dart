import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';

import 'class.dart';

void passJObjectToNative(JObject obj) {
  if (initDartAPISuccess && obj != null) {
    passJObjectToC(obj, obj.pointer);
  } else {
    print('pass object to native failed! address=${obj?.pointer}');
  }
}

class JObject extends Class {
  Pointer _ptr;

  //init target class
  JObject(String className, [Pointer ptr]) : super(className) {
    _ptr = ptr == null ? nativeCreateClass(super.classUtf8(), nullptr, nullptr) : ptr;
    passJObjectToNative(this);
  }

  JObject.parameterConstructor(String clsName, List args) : super(clsName) {
    ArgumentsPointers pointers = _parseArguments(args);

    _ptr = nativeCreateClass(super.classUtf8(), pointers.pointers, pointers.typePointers);
    passJObjectToNative(this);
    pointers.freePointers();
  }

  Pointer get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List args, String returnType, [List argsSignature]) {
    Pointer<Utf8> methodNamePtr = Utf8.toUtf8(methodName);
    Pointer<Utf8> returnTypePtr = Utf8.toUtf8(returnType);

    ArgumentsPointers pointers = _parseArguments(args, argsSignature);
    Pointer<Void> invokeMethodRet = nativeInvokeNeo(
        _ptr, methodNamePtr, pointers.pointers, pointers.typePointers, returnTypePtr);

    dynamic result = loadValueFromPointer(invokeMethodRet, returnType);
    pointers.freePointers();
    return result;
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }

  ArgumentsPointers _parseArguments(List args, [List argsSignature]) {
    Pointer<Pointer<Void>> pointers = nullptr;
    Pointer<Pointer<Utf8>> typePointers = nullptr;
    if (args != null) {
      pointers = allocate<Pointer<Void>>(count: args.length + 1);
      typePointers = allocate<Pointer<Utf8>>(count: args.length + 1);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }
        Pointer<Utf8> argSignature
            = argsSignature == null || !(argsSignature[i] is Pointer<Utf8>) ? null : argsSignature[i];
        storeValueToPointer(
            arg, pointers.elementAt(i), typePointers.elementAt(i), argSignature);
      }
      pointers.elementAt(args.length).value = nullptr;
      typePointers.elementAt(args.length).value = nullptr;
    }
    return ArgumentsPointers(pointers, typePointers);
  }
}

class ArgumentsPointers {
  Pointer<Pointer<Void>> pointers;
  Pointer<Pointer<Utf8>> typePointers;

  ArgumentsPointers(this.pointers, this.typePointers);

  void freePointers() {
    free(pointers);
    free(typePointers);
  }
}