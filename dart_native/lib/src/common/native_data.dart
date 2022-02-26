import 'dart:ffi';

abstract class NativeData {
  /// Returns a pointer to a contiguous region of memory managed by the object.
  late final Pointer<Void> bytes;
  /// The number of bytes contained by the data object.
  late final int length;
}