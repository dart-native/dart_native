import 'dart:ffi';

abstract class BytePlatformRaw {
  /// Returns a pointer to a contiguous region of memory managed by this object.
  late final Pointer<Void> bytes;

  /// Returns the length of this object, in bytes.
  late final int lengthInBytes;

  /// Pointer of native object.
  ///
  /// Objective-C pointer or JNI pointer.
  Pointer<Void> get pointer;
}
