import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';
import 'package:ffi/ffi.dart';

import 'jclass.dart';

void bindLifeCycleWithNative(JObject? obj) {
  if (initDartAPISuccess && obj != null) {
    passJObjectToC!(obj, obj.pointer.cast<Void>());
  } else {
    print('pass object to native failed! address=${obj?.pointer}');
  }
}

/// When invoke with async method, dart can set run thread.
/// [FlutterUI] is default.
enum Thread {
  /// Flutter UI thread.
  FlutterUI,

  /// Native main thread.
  MainThread,

  /// Native sub thread.
  SubThread
}

class JObject extends JClass {
  late Pointer<Void> _ptr;

  //init target class
  JObject(String className, {Pointer<Void>? pointer, bool isInterface = false})
      : super(className) {
    _ptr =
        newObject(className, this, pointer: pointer, isInterface: isInterface);
    bindLifeCycleWithNative(this);
  }

  JObject.parameterConstructor(String className, List args) : super(className) {
    _ptr = newObject(className, this, args: args);
    bindLifeCycleWithNative(this);
  }

  Pointer<Void> get pointer {
    return _ptr;
  }

  dynamic invoke(String methodName, List? args, String returnType,
      {List<String>? assignedSignature}) {
    return invokeMethod(_ptr.cast<Void>(), methodName, args, returnType,
        assignedSignature: assignedSignature);
  }

  Future<dynamic> invokeAsync(String methodName, List? args, String returnType,
      {List<String>? assignedSignature,
      Thread thread = Thread.FlutterUI}) async {
    return invokeMethodAsync(_ptr.cast<Void>(), methodName, args, returnType,
        assignedSignature: assignedSignature, thread: thread);
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }
}
