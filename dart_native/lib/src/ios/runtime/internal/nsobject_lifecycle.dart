import 'dart:ffi';

import 'package:dart_native/src/ios/common/callback_manager.dart';
import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/runtime/internal/block_lifecycle.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';

void bindLifecycleOnNative(NSObject obj) {
  // Ignore null and nil
  if (obj == null || obj == nil || obj.pointer == nullptr) {
    return;
  }

  if (!initDartAPISuccess) {
    throw 'dfailed to initialize dart API!';
  }
  // passObjectToC returns DNPassObjectResult.
  int result = passObjectToC(obj, obj.pointer);
  if (result == 0) {
    throw 'pass object to native failed! address=${obj.pointer}';
  }
  if (result == 1) {
    addFinalizerForObject(obj);
  }
}

void _dealloc(Pointer<Void> ptr) {
  if (ptr != nullptr) {
    CallbackManager.shared.clearAllCallbackOnTarget(ptr);
    removeBlockOnSequence(ptr.address);
    _finalizerMap[ptr]?.forEach((element) {
      element();
    });
    _finalizerMap.remove(ptr);
  }
}

Map<Pointer<Void>, List<Finalizer>> _finalizerMap = {};

addFinalizerForObject(NSObject obj) {
  if (obj.finalizer != null) {
    List<Finalizer> finalizers = _finalizerMap[obj.pointer];
    if (finalizers == null) {
      finalizers = [obj.finalizer];
    } else {
      finalizers.add(obj.finalizer);
    }
    _finalizerMap[obj.pointer] = finalizers;
  }
}

removeFinalizerForObject(NSObject obj) {
  List<Finalizer> finalizers = _finalizerMap[obj.pointer];
  finalizers?.remove(obj.finalizer);
}

Pointer<NativeFunction<Void Function(Pointer<Void>)>> nativeObjectDeallocPtr =
    Pointer.fromFunction(_dealloc);
