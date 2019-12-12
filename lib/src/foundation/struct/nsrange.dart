import 'dart:ffi';

import 'package:dart_objc/src/foundation/internal/native_struct.dart';

class NSRange extends NSUIntegerx2Wrapper {
  int get location => a;
  set location(int location) {
    a = location;
  }

  int get length => b;
  set length(int length) {
    b = length;
  }

  NSRange(int width, int length) : super(width, length);
  NSRange.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
