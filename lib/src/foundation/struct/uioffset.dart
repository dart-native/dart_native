import 'dart:ffi';

import 'package:dart_objc/src/foundation/internal/native_struct.dart';

class UIOffset extends CGFloatx2Wrapper {
  double get horizontal => a;
  set horizontal(double width) {
    a = width;
  }

  double get vertical => b;
  set vertical(double height) {
    b = height;
  }

  UIOffset(double horizontal, double vertical) : super(horizontal, vertical);
  UIOffset.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
