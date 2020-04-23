import 'dart:ffi';

import 'package:dart_native/src/ios/common/pointer_wrapper.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:ffi/ffi.dart';

class NSObjectRef<T extends NSObject> {
  T value = nil;
  Pointer<Pointer<Void>> _ptr;
  Pointer<Pointer<Void>> get pointer => _ptr;

  NSObjectRef(this.value) {
    _ptr = allocate<Pointer<Void>>();
  }

  NSObjectRef.fromPointer(this._ptr) {
    if (_ptr == null) {
      _ptr = nullptr;
    } else {
      value = convertFromPointer(T.runtimeType.toString(), _ptr);
    }
  }

  void makePointerWrapper(Pointer<Pointer<Void>> ptr) {
    PointerWrapper wrapper = PointerWrapper(_dealloc);
    wrapper.value = _ptr.cast<Void>();
  }

  void _dealloc() {
    _ptr = nullptr;
    value = nil;
  }
}