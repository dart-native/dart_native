import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSRange` in iOS and macOS.
@native()
class NSRange extends NSUIntegerx2Wrapper {
  @override
  String get aliasForNSValue => 'Range';

  int get location => i1;
  set location(int location) {
    i1 = location;
  }

  int get length => i2;
  set length(int length) {
    i2 = length;
  }

  NSRange(int width, int length) : super(width, length);
  NSRange.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
