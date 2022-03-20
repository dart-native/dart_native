import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/common/bytes_pointer_raw.dart';

/// Byte buffers representing each native platform.
///
/// [NativeByte] is responsible for managing the life cycle of the byte buffer.
/// [NativeByte] is read-only. If you want to change the byte buffer, you can use
/// either [Pointer] or [ByteBuffer], but you need to manually manage the life cycle.
class NativeByte {
  /// A pointer points to bytes on the heap.
  Pointer<Void> get bytes => raw.bytes;

  /// Returns the length of this byte buffer, in bytes.
  int get lengthInBytes => raw.lengthInBytes;

  /// The Raw object on the current platform.
  late final BytePlatformRaw raw;

  NativeByte(Pointer<Void> bytes, int lengthInBytes) {
    if (Platform.isIOS || Platform.isMacOS) {
      raw = NSData(bytes, lengthInBytes);
    } else if (Platform.isAndroid) {
      // TODO: support data on Android
    } else {
      throw 'Platform not supported: ${Platform.localeName}';
    }
  }

  NativeByte.fromRaw(this.raw);
}
