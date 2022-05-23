import 'dart:ffi';

import 'package:dart_native/src/darwin/common/callback_manager.dart';
import 'package:dart_native/src/darwin/common/library.dart';
import 'package:dart_native/src/darwin/runtime/internal/block_lifecycle.dart';
import 'package:dart_native/src/darwin/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/darwin/runtime/nsobject.dart';

void bindLifecycleForObject(NSObject obj) {
  // Ignore null and nil
  if (obj == nil || obj.pointer == nullptr) {
    return;
  }

  if (!initDartAPISuccess) {
    throw 'failed to initialize dart API!';
  }
  // passObjectToC returns DNPassObjectResult.
  int result = bindObjcLifecycleToDart(obj, obj.pointer);
  if (result == 0) {
    throw 'pass object to native failed! address=${obj.pointer}';
  }
}

void _dealloc(Pointer<Void> ptr) {
  if (ptr != nullptr) {
    CallbackManager.shared.clearAllCallbackOnTarget(ptr);
    removeBlockOnSequence(ptr.address);
  }
}

Pointer<NativeFunction<Void Function(Pointer<Void>)>> nativeObjectDeallocPtr =
    Pointer.fromFunction(_dealloc);
