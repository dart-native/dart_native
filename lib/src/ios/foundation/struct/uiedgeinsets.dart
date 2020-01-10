import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

class UIEdgeInsets extends CGFloatx4Wrapper {
  double get top => a;
  set top(double top) {
    a = top;
  }

  double get left => b;
  set left(double left) {
    b = left;
  }

  double get bottom => c;
  set bottom(double bottom) {
    c = bottom;
  }

  double get right => d;
  set right(double right) {
    d = right;
  }

  UIEdgeInsets(double top, double left, double bottom, double right)
      : super(top, left, bottom, right);
  UIEdgeInsets.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
