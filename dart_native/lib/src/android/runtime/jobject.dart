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

class JObject extends Class{
  Pointer _ptr;

  //init target class
  JObject(String className, Pointer ptr) : super(className) {
    _ptr = ptr == null ? nativeCreateClass(super.classUtf8()) : ptr;
    passJObjectToNative(this);
  }

  Pointer get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List args, [String returnType]) {
    int startT = currentTimeMillis();
    print("prepare startT: $startT");
    Pointer<Utf8> methodNamePtr = Utf8.toUtf8(methodName);
    Pointer<Utf8> returnTypePtr = Utf8.toUtf8(returnType);
    Pointer<Pointer<Void>> pointers;
    Pointer<Pointer<Utf8>> typePointers;
    if (args != null) {
      pointers = allocate<Pointer<Void>>(count: args.length + 1);
      typePointers = allocate<Pointer<Utf8>>(count: args.length + 1);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }
        storeValueToPointer(arg, pointers.elementAt(i), typePointers.elementAt(i));
      }
      pointers.elementAt(args.length).value = nullptr;
      typePointers.elementAt(args.length).value = nullptr;
    }
    int use = currentTimeMillis() - startT;
    print("prepare cost: $use, start: $startT");

    startT = currentTimeMillis();
    Pointer<Void> invokeMethodRet =
        nativeInvokeNeo(_ptr, methodNamePtr, pointers, typePointers, returnTypePtr);
    use = currentTimeMillis() - startT;
    print("invoke cost: $use");

    startT = currentTimeMillis();
    dynamic result = loadValueFromPointer(invokeMethodRet, returnType);
    use = currentTimeMillis() - startT;
    print("loadValueFromPointer cost: $use");

    startT = currentTimeMillis();
    if (pointers != null) {
      free(pointers);
    }
    if (typePointers != null) {
      free(typePointers);
    }
    use = currentTimeMillis() - startT;
    print("free cost: $use");

    startT = currentTimeMillis();
    print("print test");
    int end = currentTimeMillis();
    use = end - startT;
    print("print and get time cost: $use, end: $end");

    return result;
  }

  int currentTimeMillis() {
    return new DateTime.now().microsecondsSinceEpoch;
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }
}
