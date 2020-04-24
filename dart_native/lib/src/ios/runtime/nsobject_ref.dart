import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:ffi/ffi.dart';

class NSObjectRef<T extends id> {
  T value;
  Pointer<Pointer<Void>> _ptr;
  Pointer<Pointer<Void>> get pointer => _ptr;

  NSObjectRef() {
    _ptr = allocate<Pointer<Void>>();
    _ptr.value = nullptr;
  }

  NSObjectRef.fromPointer(this._ptr);

  syncValue() {
    if (_ptr != null && _ptr.value != nullptr) {
      value = convertFromPointer(T.toString(), _ptr.value);
      free(_ptr);
      _ptr = null;
    }
  }
}