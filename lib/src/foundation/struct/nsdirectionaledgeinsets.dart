import 'dart:ffi';

import 'package:dart_objc/src/foundation/internal/native_struct.dart';

class NSDirectionalEdgeInsets extends CGFloatx4Wrapper {
  double get top => a;
  set top(double top) {
    a = top;
  }

  double get leading => b;
  set leading(double leading) {
    b = leading;
  }

  double get bottom => c;
  set bottom(double bottom) {
    c = bottom;
  }

  double get trailing => d;
  set trailing(double trailing) {
    d = trailing;
  }

  NSDirectionalEdgeInsets(
      double top, double leading, double bottom, double trailing)
      : super(top, leading, bottom, trailing);
  NSDirectionalEdgeInsets.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr);
}
