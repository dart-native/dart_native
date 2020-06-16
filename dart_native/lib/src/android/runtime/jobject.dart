import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';

import 'JObjectPool.dart';
import 'class.dart';

class JObject extends Class{
  Pointer _ptr;
  Map<String, Pointer> _methodNameCache = {};
  Map<String, Pointer> _methodSignatureCache = {};

  //init target class
  JObject(String className, Pointer ptr) : super(className) {
    print("ptr value ${ptr == null}");
    _ptr = ptr == null ? nativeCreateClass(super.classUtf8()) : ptr;
    JObjectPool.sInstance.retain(this);
  }

  Pointer get pointer{
    return _ptr;
  }

  dynamic invoke(String methodName, String methodSignature, List args) {
    Pointer<Utf8> methodNamePtr = _methodNameCache[methodName];
    if(methodNamePtr == null) {
      methodNamePtr = Utf8.toUtf8(methodName);
      _methodNameCache[methodName] = methodNamePtr;
    }

    Pointer<Utf8> methodSignaturePtr = _methodSignatureCache[methodSignature];
    if(methodSignaturePtr == null) {
      methodSignaturePtr = Utf8.toUtf8(methodSignature);
      _methodSignatureCache[methodSignature] = methodSignaturePtr;
    }

    Pointer<Pointer<Void>> pointers;
    if (args != null) {
      pointers = allocate<Pointer<Void>>(count: args.length + 1);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }
        TypeDecoding argType = argumentSignatureDecoding(methodSignature, i);
        storeValueToPointer(arg, pointers.elementAt(i), argType);
      }
      pointers.elementAt(args.length).value = nullptr;
    }
    Pointer<Void> invokeMethodRet =
        nativeInvoke(_ptr, methodNamePtr, pointers, methodSignaturePtr);
    if (pointers != null) {
      free(pointers);
    }
    TypeDecoding returnType =
        argumentSignatureDecoding(methodSignature, 0, true);
    dynamic result = loadValueFromPointer(invokeMethodRet, returnType);
    return result;
  }

  release() {
    if (JObjectPool.sInstance.release(this)) {
      nativeReleaseClass(_ptr);
    }
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }
}
