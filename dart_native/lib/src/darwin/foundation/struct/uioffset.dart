import 'dart:ffi';

import 'package:dart_native/src/darwin/foundation/internal/native_struct.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `UIOffset` in iOS.
@native()
class UIOffset extends CGFloatx2Wrapper {
  double get horizontal => d1;
  set horizontal(double width) {
    d1 = width;
  }

  double get vertical => d2;
  set vertical(double height) {
    d2 = height;
  }

  UIOffset(double horizontal, double vertical) : super(horizontal, vertical);
  UIOffset.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
