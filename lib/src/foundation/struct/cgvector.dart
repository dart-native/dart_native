import 'dart:ffi';

import 'package:dart_objc/src/foundation/internal/native_struct.dart';

class CGVector extends CGFloatx2Wrapper {
  double get dx => a;
  set dx(double dx) {
    a = dx;
  }

  double get dy => b;
  set dy(double dy) {
    b = dy;
  }

  CGVector(double dx, double dy) : super(dx, dy);
  CGVector.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
