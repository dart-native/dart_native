import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native()
class NSData extends NSObject implements NativeData {
  @override
  late final Pointer<Void> bytes;
  @override
  late final int length;

  NSData(this.bytes, this.length) : super.fromPointer(_dataWithBytes(bytes, length));
  NSData.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    bytes = perform(SEL('bytes'), decodeRetVal: false);
    length = perform(SEL('length'));
  }

  static Pointer<Void> _dataWithBytes(Pointer<Void> bytes, int length) {
    return Class('NSData').perform(SEL('dataWithBytes:length:'),
        args: [bytes, length], decodeRetVal: false);
  }
}
