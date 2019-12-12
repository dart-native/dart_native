import 'dart:ffi';

import 'package:dart_objc/src/foundation/internal/native_struct.dart';

class CGRect extends CGFloatx4Wrapper {
  double get x => a;
  set x(double x) {
    a = x;
  }

  double get y => b;
  set y(double y) {
    b = y;
  }

  double get width => c;
  set width(double width) {
    c = width;
  }

  double get height => d;
  set height(double height) {
    d = height;
  }

  CGRect(double x, double y, double width, double height)
      : super(x, y, width, height);
  CGRect.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
