import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

/// Stands for `CGSize` in iOS and macOS.
class CGSize extends CGFloatx2Wrapper {
  double get width => d1;
  set width(double width) {
    d1 = width;
  }

  double get height => d2;
  set height(double height) {
    d2 = height;
  }

  CGSize(double width, double height) : super(width, height);
  CGSize.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

/// Stands for `NSSize` in macOS.
class NSSize extends CGSize {
  @override
  String get aliasForNSValue => 'Size';

  NSSize(double width, double height) : super(width, height);
  NSSize.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
