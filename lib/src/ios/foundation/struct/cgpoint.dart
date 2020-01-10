import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

class CGPoint extends CGFloatx2Wrapper {
  double get x => a;
  set x(double x) {
    a = x;
  }

  double get y => b;
  set y(double y) {
    b = y;
  }

  CGPoint(double x, double y) : super(x, y);
  CGPoint.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
