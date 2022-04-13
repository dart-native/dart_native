import 'dart:ffi';

import 'package:dart_native/src/darwin/foundation/internal/native_struct.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `CGVector` in iOS and macOS.
@native()
class CGVector extends CGFloatx2Wrapper {
  double get dx => d1;
  set dx(double dx) {
    d1 = dx;
  }

  double get dy => d2;
  set dy(double dy) {
    d2 = dy;
  }

  CGVector(double dx, double dy) : super(dx, dy);
  CGVector.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
