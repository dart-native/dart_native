import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

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
