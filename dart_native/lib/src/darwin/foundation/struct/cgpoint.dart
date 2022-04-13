import 'dart:ffi';

import 'package:dart_native/src/darwin/foundation/internal/native_struct.dart';

/// Stands for `CGPoint` in iOS and macOS.
class CGPoint extends CGFloatx2Wrapper {
  double get x => d1;
  set x(double x) {
    d1 = x;
  }

  double get y => d2;
  set y(double y) {
    d2 = y;
  }

  CGPoint(double x, double y) : super(x, y);
  CGPoint.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

/// Stands for `NSPoint` in macOS.
class NSPoint extends CGPoint {
  @override
  String get aliasForNSValue => 'Point';

  NSPoint(double x, double y) : super(x, y);
  NSPoint.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
