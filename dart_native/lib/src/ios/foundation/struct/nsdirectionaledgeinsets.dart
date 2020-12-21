import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';

/// Stands for `NSDirectionalEdgeInsets` in iOS.
class NSDirectionalEdgeInsets extends CGFloatx4Wrapper {
  double get top => d1;
  set top(double top) {
    d1 = top;
  }

  double get leading => d2;
  set leading(double leading) {
    d2 = leading;
  }

  double get bottom => d3;
  set bottom(double bottom) {
    d3 = bottom;
  }

  double get trailing => d4;
  set trailing(double trailing) {
    d4 = trailing;
  }

  NSDirectionalEdgeInsets(
      double top, double leading, double bottom, double trailing)
      : super(top, leading, bottom, trailing);
  NSDirectionalEdgeInsets.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr);
}
