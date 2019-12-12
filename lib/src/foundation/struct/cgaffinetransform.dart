import 'dart:ffi';

import 'package:dart_objc/src/foundation/internal/native_struct.dart';

class CGAffineTransform extends CGFloatx6Wrapper {
  double get tx => e;
  set tx(double tx) {
    e = tx;
  }

  double get ty => f;
  set ty(double ty) {
    f = ty;
  }

  CGAffineTransform(
      double a, double b, double c, double d, double tx, double ty)
      : super(a, b, c, d, tx, ty);
  CGAffineTransform.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
