import 'dart:ffi';

abstract class BytesPointerRaw {
  /// Returns a pointer to a contiguous region of memory managed by the object.
  late final Pointer<Void> bytes;

  /// The number of bytes contained by the data object.
  late final int lengthInBytes;

  /// Pointer of native object.
  ///
  /// Objective-C pointer or JNI pointer.
  Pointer<Void> get pointer;
}
