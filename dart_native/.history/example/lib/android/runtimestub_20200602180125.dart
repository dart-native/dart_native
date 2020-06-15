import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:ffi';

class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  String getString(String s) {
    Pointer<Pointer<Void>> pointers;
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
    nativeInvoke(["xxxx"]);
  }
}
