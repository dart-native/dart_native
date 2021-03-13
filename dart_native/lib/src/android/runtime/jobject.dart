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
  JObject(String className, [this._ptr]) : super(className) {
    if (_ptr == null) {
      Pointer<Utf8> classNamePtr = super.className.toNativeUtf8();
      _ptr = nativeCreateClass(classNamePtr);
      calloc.free(classNamePtr);
    }
    passJObjectToNative(this);
  }

  Pointer get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List args, [String returnType]) {
    Pointer<Utf8> methodNamePtr = methodName.toNativeUtf8();
    Pointer<Utf8> returnTypePtr = returnType.toNativeUtf8();

    Pointer<Pointer<Void>> pointers;
    Pointer<Pointer<Utf8>> typePointers;
    if (args != null) {
      pointers = calloc<Pointer<Void>>(args.length + 1);
      typePointers = calloc<Pointer<Utf8>>(args.length + 1);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }
        storeValueToPointer(
            arg, pointers.elementAt(i), typePointers.elementAt(i));
      }
      pointers.elementAt(args.length).value = nullptr;
      typePointers.elementAt(args.length).value = nullptr;
    }
    Pointer<Void> invokeMethodRet = nativeInvokeNeo(
        _ptr, methodNamePtr, pointers, typePointers, returnTypePtr);
    dynamic result = loadValueFromPointer(invokeMethodRet, returnType);
    calloc.free(methodNamePtr);
    calloc.free(returnTypePtr);
    if (pointers != null) {
      calloc.free(pointers);
    }
    if (typePointers != null) {
      calloc.free(typePointers);
    }
    return result;
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }
}
