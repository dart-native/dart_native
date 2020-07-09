import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

class CGSize extends CGFloatx2Wrapper {
  double get width => d1;
  set width(double width) {
    d1 = width;
  }

  double get height => d2;
  set height(double height) {
    d2 = height;
  }

  CGSize(double width, double height) : super(width, height);
  CGSize.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
