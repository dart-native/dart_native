import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/runtime/message.dart';
import 'package:ffi/ffi.dart';

import 'jclass.dart';

void bindLifeCycleWithNative(JObject? obj) {
  if (initDartAPISuccess && obj != null) {
    passJObjectToC!(obj, obj.pointer.cast<Void>());
  } else {
    print('pass object to native failed! address=${obj?.pointer}');
  }
}

class JObject extends JClass {
  late Pointer<Void> _ptr;

  //init target class
  JObject(String className, {Pointer<Void>? pointer, bool isInterface = false})
      : super(className) {
    _ptr = _new(className, pointer: pointer, isInterface: isInterface);
    bindLifeCycleWithNative(this);
  }

  JObject.parameterConstructor(String className, List args) : super(className) {
    _ptr = newObject(className, args: args);
    bindLifeCycleWithNative(this);
  }

  Pointer<Void> get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List? args, String returnType,
      {List? argsSignature}) {
    return invokeMethod(_ptr.cast<Void>(), methodName, args, returnType,
        argsSignature: argsSignature);
  }

  Future<dynamic> invokeAsync(String methodName, List? args, String returnType,
      {List? argsSignature}) async {
    return invokeMethodAsync(_ptr.cast<Void>(), methodName, args, returnType,
        argsSignature: argsSignature);
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }

  Pointer<Void> _new(String className,
      {Pointer<Void>? pointer, bool isInterface = false}) {
    if (isInterface) {
      Pointer<Int64> hashPointer = calloc<Int64>();
      hashPointer.value = identityHashCode(this);
      return hashPointer.cast<Void>();
    }

    if (pointer == null) {
      return newObject(className);
    }
    return pointer;
  }
}
