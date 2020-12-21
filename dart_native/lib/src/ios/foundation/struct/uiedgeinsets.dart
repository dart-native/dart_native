import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

/// Stands for `UIEdgeInsets` in iOS.
class UIEdgeInsets extends CGFloatx4Wrapper {
  double get top => d1;
  set top(double top) {
    d1 = top;
  }

  double get left => d2;
  set left(double left) {
    d2 = left;
  }

  double get bottom => d3;
  set bottom(double bottom) {
    d3 = bottom;
  }

  double get right => d4;
  set right(double right) {
    d4 = right;
  }

  UIEdgeInsets(double top, double left, double bottom, double right)
      : super(top, left, bottom, right);
  UIEdgeInsets.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
