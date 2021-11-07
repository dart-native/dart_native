import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/common/native_basic_type.dart';

import 'jclass.dart';

void passJObjectToNative(JObject? obj) {
  if (initDartAPISuccess && obj != null) {
    passJObjectToC!(obj, obj.pointer.cast<Void>());
  } else {
    print('pass object to native failed! address=${obj?.pointer}');
  }
}

class JObject extends JClass {
  late Pointer _ptr;

  //init target class
  JObject(String className, {Pointer? pointer, bool isInterface = false})
      : super(className) {
    if (isInterface) {
      Pointer<Int64> hashPointer = calloc<Int64>();
      hashPointer.value = identityHashCode(this);
      _ptr = hashPointer.cast<Void>();
      return;
    }

    if (pointer == null) {
      Pointer<Utf8> classNamePtr = super.className.toNativeUtf8();
      pointer = nativeCreateObject!(
          classNamePtr, nullptr.cast(), nullptr.cast(), 0, 0);
      calloc.free(classNamePtr);
    }

    _ptr = pointer;
    passJObjectToNative(this);
  }

  JObject.parameterConstructor(String clsName, List args) : super(clsName) {
    NativeArguments nativeArguments = _parseNativeArguments(args);
    Pointer<Utf8> classNamePtr = super.className.toNativeUtf8();
    _ptr = nativeCreateObject!(
        classNamePtr,
        nativeArguments.pointers,
        nativeArguments.typePointers,
        args.length,
        nativeArguments.stringTypeBitmask);
    calloc.free(classNamePtr);
    passJObjectToNative(this);
    nativeArguments.freePointers();
  }

  Pointer get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List? args, String returnType,
      {List? argsSignature}) {
    Pointer<Utf8> methodNamePtr = methodName.toNativeUtf8();
    Pointer<Utf8> returnTypePtr = returnType.toNativeUtf8();

    NativeArguments nativeArguments =
        _parseNativeArguments(args, argsSignature: argsSignature);
    Pointer<Void> invokeMethodRet = nativeInvoke!(
        _ptr.cast<Void>(),
        methodNamePtr,
        nativeArguments.pointers,
        nativeArguments.typePointers,
        args?.length ?? 0,
        returnTypePtr,
        nativeArguments.stringTypeBitmask);

    dynamic result = loadValueFromPointer(invokeMethodRet, returnType,
        typePtr: nativeArguments.typePointers.elementAt(args?.length ?? 0));

    nativeArguments.freePointers();
    calloc.free(methodNamePtr);
    calloc.free(returnTypePtr);
    return result;
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }

  NativeArguments _parseNativeArguments(List? args, {List? argsSignature}) {
    Pointer<Pointer<Void>> pointers = nullptr.cast();

    /// extend a bit for string
    Pointer<Pointer<Utf8>>? typePointers =
        calloc<Pointer<Utf8>>((args?.length ?? 0) + 1);
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

        Pointer<Utf8> argSignature =
            argsSignature == null || !(argsSignature[i] is Pointer<Utf8>)
                ? null
                : argsSignature[i];

        if (arg is String) {
          stringTypeBitmask |= (0x1 << i);
        }

        storeValueToPointer(arg, pointers.elementAt(pi),
            typePtr: typePointers.elementAt(i), argSignature: argSignature);

        /// check 32 bit system
        if (!is64Bit && (arg is double || arg is long)) {
          pi++;
        }
      }
    }
    typePointers.elementAt(args?.length ?? 0).value = "0".toNativeUtf8();
    return NativeArguments(pointers, typePointers, stringTypeBitmask);
  }
}

class NativeArguments {
  final Pointer<Pointer<Void>> pointers;
  final Pointer<Pointer<Utf8>> typePointers;
  int stringTypeBitmask;

  NativeArguments(this.pointers, this.typePointers, this.stringTypeBitmask);

  void freePointers() {
    //if (pointers != null) {
    calloc.free(pointers);
    //}
    //  if (typePointers != null) {
    calloc.free(typePointers);
    //}
  }
}
