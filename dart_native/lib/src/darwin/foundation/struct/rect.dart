import 'dart:ffi';

import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/src/darwin/foundation/internal/native_struct.dart';

/// Stands for `CGRect` in iOS and macOS.
@native()
class CGRect extends CGFloatx4Wrapper {
  double get x => d1;
  set x(double x) {
    d1 = x;
  }

  double get y => d2;
  set y(double y) {
    d2 = y;
  }

  double get width => d3;
  set width(double width) {
    d3 = width;
  }

  double get height => d4;
  set height(double height) {
    d4 = height;
  }

  CGRect(double x, double y, double width, double height)
      : super(x, y, width, height);
  CGRect.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

/// Stands for `NSRect` in macOS.
@native()
class NSRect extends CGRect {
  @override
  String get aliasForNSValue => 'Rect';

  NSRect(double x, double y, double width, double height)
      : super(x, y, width, height);
  NSRect.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
