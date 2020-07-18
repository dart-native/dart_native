import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

class CATransform3D extends CGFloatx16Wrapper {
  double get m11 => d1;
  set m11(double m11) {
    d1 = m11;
  }

  double get m12 => d2;
  set m12(double m12) {
    d2 = m12;
  }

  double get m13 => d3;
  set m13(double m13) {
    d3 = m13;
  }

  double get m14 => d4;
  set m14(double m14) {
    d4 = m14;
  }

  double get m21 => d5;
  set m21(double m21) {
    d5 = m21;
  }

  double get m22 => d6;
  set m22(double m22) {
    d6 = m22;
  }

  double get m23 => d7;
  set m23(double m23) {
    d7 = m23;
  }

  double get m24 => d8;
  set m24(double m24) {
    d8 = m24;
  }

  double get m31 => d9;
  set m31(double m31) {
    d9 = m31;
  }

  double get m32 => d10;
  set m32(double m32) {
    d10 = m32;
  }

  double get m33 => d11;
  set m33(double m33) {
    d11 = m33;
  }

  double get m34 => d12;
  set m34(double m34) {
    d12 = m34;
  }

  double get m41 => d13;
  set m41(double m41) {
    d13 = m41;
  }

  double get m42 => d14;
  set m42(double m42) {
    d14 = m42;
  }

  double get m43 => d15;
  set m43(double m43) {
    d15 = m43;
  }

  double get m44 => d16;
  set m44(double m44) {
    d16 = m44;
  }

  CATransform3D(
      double m11,
      double m12,
      double m13,
      double m14,
      double m21,
      double m22,
      double m23,
      double m24,
      double m31,
      double m32,
      double m33,
      double m34,
      double m41,
      double m42,
      double m43,
      double m44)
      : super(m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41,
            m42, m43, m44);
  CATransform3D.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
