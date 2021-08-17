import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

/// Stands for `UIOffset` in iOS.
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
