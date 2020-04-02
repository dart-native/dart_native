import 'dart:ffi';
import 'package:dart_native/src.android/runtime/functions.dart';
import 'package:dart_native/src.android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';

class JObject {

  //init target class
  void setTargetClass(String className) {
    final clsNamePtr = Utf8.toUtf8(className);
    targetClass(clsNamePtr);
  }

  //todo args nativeTypeEncoding
  dynamic invoke(String method, List args, [bool isFloat = false]) {
    final methodPtr = Utf8.toUtf8(method);

    Pointer<Utf8> typePtr = nativeMethodType(methodPtr);
    String returnType = Utf8.fromUtf8(typePtr);
    print("returnType $returnType");
    free(typePtr);

    Pointer<Pointer<Void>> pointers;
    if (args != null) {
      pointers = allocate<Pointer<Void>>(count: args.length + 1);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }
        storeValueToPointer(arg, pointers.elementAt(i), isFloat);
      }
      pointers.elementAt(args.length).value = nullptr;
    }
    Pointer<Void> invokeMethod = invokeNativeMethod(methodPtr, pointers);
    if(pointers != null) {
      free(pointers);
    }
    dynamic result = loadValueFromPointer(invokeMethod, returnType);
    return result;
  }
}

