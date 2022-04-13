import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/common/bytes_pointer_raw.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSData` in iOS and macOS.
@native()
class NSData extends NSObject implements BytePlatformRaw {
  @override
  late final Pointer<Void> bytes;
  @override
  late final int lengthInBytes;

  NSData(this.bytes, this.lengthInBytes)
      : super.fromPointer(_dataWithBytes(bytes, lengthInBytes));
  NSData.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    bytes = performSync(SEL('bytes'), decodeRetVal: false);
    lengthInBytes = performSync(SEL('length'));
  }

  static Pointer<Void> _dataWithBytes(Pointer<Void> bytes, int lengthInBytes) {
    return Class('NSData').performSync(SEL('dataWithBytes:length:'),
        args: [bytes, lengthInBytes], decodeRetVal: false);
  }
}
