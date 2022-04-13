import 'dart:ffi';

import 'package:dart_native/src/darwin/common/pointer_wrapper.dart';
import 'package:dart_native/src/darwin/runtime/id.dart';
import 'package:dart_native/src/darwin/runtime/nsobject.dart';
import 'package:ffi/ffi.dart';

/// Stands for `NSObject **` in iOS and macOS.
///
/// This Class is an experimental implementation.
/// Broken changes are likely in the future.
class NSObjectRef<T extends id> {
  late T value;
  late Pointer<Pointer<Void>> _ptr;
  Pointer<Pointer<Void>> get pointer => _ptr;
  late final PointerWrapper _wrapper = PointerWrapper(_ptr.cast<Void>());

  NSObjectRef() {
    _ptr = calloc<Pointer<Void>>();
    _ptr.value = nullptr;
    _wrapper;
  }

  NSObjectRef.fromPointer(Pointer<Pointer<Void>> ptr) {
    _ptr = calloc<Pointer<Void>>();
    _ptr.value = ptr.value;
    _wrapper;
  }

  syncValue() {
    if (_ptr.value != nullptr) {
      value = objcInstanceFromPointer(_ptr.value, T.toString());
    }
  }
}
