import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/common/bytes_pointer_raw.dart';

class NativeBuffer {
  Pointer<Void> get bytes => raw.bytes;
  int get lengthInBytes => raw.lengthInBytes;
  late final BytesPointerRaw raw;

  NativeBuffer(Pointer<Void> bytes, int lengthInBytes) {
    if (Platform.isIOS || Platform.isMacOS) {
      raw = NSData(bytes, lengthInBytes);
    } else if (Platform.isAndroid) {
      // TODO: support data on Android
    } else {
      throw 'Platform not supported: ${Platform.localeName}';
    }
  }

  NativeBuffer.fromRaw(this.raw);
}
