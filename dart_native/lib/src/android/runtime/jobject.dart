import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/common/library.dart';
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
  JObject(String className, {Pointer pointer, bool isInterface = false}) : super(className) {
    if (isInterface) {
      Pointer<Int64> hashPointer = allocate();
      hashPointer.value = identityHashCode(this);
      _ptr = hashPointer.cast<Void>();
      return;
    }

    if (pointer == null) {
      Pointer<Utf8> classNamePtr = Utf8.toUtf8(super.className);
      pointer = nativeCreateClass(classNamePtr, nullptr, nullptr, 0);
      free(classNamePtr);
    }

    _ptr = pointer;
    passJObjectToNative(this);
  }

  JObject.parameterConstructor(String clsName, List args) : super(clsName) {
    ArgumentsPointers pointers = _parseArguments(args);
    Pointer<Utf8> classNamePtr = Utf8.toUtf8(super.className);
    _ptr = nativeCreateClass(
        classNamePtr, pointers.pointers, pointers.typePointers, args?.length ?? 0);
    free(classNamePtr);
    passJObjectToNative(this);
    pointers.freePointers();
  }

  Pointer get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List args, String returnType,
      [List argsSignature]) {
    Pointer<Utf8> methodNamePtr = Utf8.toUtf8(methodName);
    Pointer<Utf8> returnTypePtr = Utf8.toUtf8(returnType);

    ArgumentsPointers pointers = _parseArguments(args, argsSignature);
    Pointer<Void> invokeMethodRet = nativeInvokeNeo(_ptr, methodNamePtr,
        pointers.pointers, pointers.typePointers, args?.length ?? 0, returnTypePtr);

    dynamic result = loadValueFromPointer(invokeMethodRet, returnType);
    pointers.freePointers();
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

  ArgumentsPointers _parseArguments(List args, [List argsSignature]) {
    Pointer<Pointer<Void>> pointers = nullptr;
    Pointer<Pointer<Utf8>> typePointers = nullptr;
    if (args != null) {
      pointers = allocate<Pointer<Void>>(count: args.length);
      typePointers = allocate<Pointer<Utf8>>(count: args.length);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }
        Pointer<Utf8> argSignature =
            argsSignature == null || !(argsSignature[i] is Pointer<Utf8>)
                ? null
                : argsSignature[i];
        storeValueToPointer(arg, pointers.elementAt(i),
            typePointers.elementAt(i), argSignature);
      }
    }
    if (pointers == nullptr) {
      pointers = nullptr.cast();
    }

    if (typePointers == nullptr) {
      typePointers = nullptr.cast();
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
