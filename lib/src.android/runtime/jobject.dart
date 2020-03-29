import 'dart:ffi';
import 'package:dart_native/src.android/runtime/functions.dart';
import 'package:dart_native/src.android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';

class JObject {

  dynamic invoke(String method, List args) {
    final methodPtr = Utf8.toUtf8(method);

//    Pointer<Void> nativeMethodPtr = nativeMethod(methodPtr);
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
        storeValueToPointer(arg, pointers.elementAt(i));
      }
    }
    Pointer<Utf8> invokeMethod = invokeNativeMethod(methodPtr, pointers);
    if(pointers != null) {
      free(pointers);
    }


    //covert dart type to native

    //covert native type to dart

    //return
    dynamic result = loadValueFromPointer(invokeMethod, returnType);
    return result;
  }
}

