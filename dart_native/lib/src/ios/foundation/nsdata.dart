import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/common/bytes_pointer_raw.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native()
class NSData extends NSObject implements BytesPointerRaw {
  @override
  late final Pointer<Void> bytes;
  @override
  late final int lengthInBytes;

  NSData(this.bytes, this.lengthInBytes)
      : super.fromPointer(_dataWithBytes(bytes, lengthInBytes));
  NSData.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    bytes = perform(SEL('bytes'), decodeRetVal: false);
    lengthInBytes = perform(SEL('length'));
  }

  static Pointer<Void> _dataWithBytes(Pointer<Void> bytes, int lengthInBytes) {
    return Class('NSData').perform(SEL('dataWithBytes:length:'),
        args: [bytes, lengthInBytes], decodeRetVal: false);
  }
}
