import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

class CGAffineTransform extends CGFloatx6Wrapper {
  double get a => d1;
  set a(double a) {
    d1 = a;
  }

  double get b => d2;
  set b(double b) {
    d2 = b;
  }

  double get c => d3;
  set c(double c) {
    d3 = c;
  }

  double get d => d4;
  set d(double d) {
    d4 = d;
  }

  double get tx => d5;
  set tx(double tx) {
    d5 = tx;
  }

  double get ty => d6;
  set ty(double ty) {
    d6 = ty;
  }

  CGAffineTransform(
      double a, double b, double c, double d, double tx, double ty)
      : super(a, b, c, d, tx, ty);
  CGAffineTransform.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
