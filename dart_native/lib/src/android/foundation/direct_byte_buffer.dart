import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/common/bytes_pointer_raw.dart';

/// Stands for 'java/nio/DirectByteBuffer' in java.
/// It's a more efficient way to use jni method direct get buffer info and create buffer.
///
/// JNI Interface: [NewDirectByteBuffer], [GetDirectBufferAddress], [GetDirectBufferCapacity]
class DirectByteBuffer implements BytePlatformRaw {
  /// DirectByteBuffer java object pointer.
  late Pointer<Void> _ptr;

  @override
  Pointer<Void> get pointer => _ptr;

  @override
  late Pointer<Void> bytes;

  @override
  late int lengthInBytes;

  DirectByteBuffer(this.bytes, this.lengthInBytes) {
    if (bytes == nullptr || lengthInBytes == 0) {
      _ptr = nullptr;
      return;
    }
    _ptr = _newDirectByteBuffer(bytes, lengthInBytes);
    bindLifeCycleWithJava(_ptr);
  }

  DirectByteBuffer.fromPointer(Pointer<Void> pointer) {
    _ptr = pointer;
    bindLifeCycleWithJava(_ptr);
    bytes = pointer != nullptr ? _getDirectByteBufferData(pointer) : nullptr;
    lengthInBytes = pointer != nullptr ? _getDirectByteBufferSize(pointer) : 0;
  }
}

/// new direct byte buffer in jni
final Pointer<Void> Function(Pointer<Void>, int) _newDirectByteBuffer =
    nativeDylib
        .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>, Int64)>>(
            'NewDirectByteBuffer')
        .asFunction();

/// get direct byte buffer data in jni
final Pointer<Void> Function(Pointer<Void>) _getDirectByteBufferData =
    nativeDylib
        .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
            'GetDirectByteBufferData')
        .asFunction();

/// get direct byte buffer size in jni
final int Function(Pointer<Void>) _getDirectByteBufferSize = nativeDylib
    .lookup<NativeFunction<Int64 Function(Pointer<Void>)>>(
        'GetDirectByteBufferSize')
    .asFunction();
