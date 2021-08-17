import 'dart:ffi';

import 'package:dart_native/src/ios/common/precompile_macro.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/ios/common/pointer_wrapper.dart';

abstract class NativeStruct {
  Pointer get addressOf;

  PointerWrapper _wrapper;
  PointerWrapper get wrapper {
    if (_wrapper == null) {
      _wrapper = PointerWrapper();
    }
    Pointer<Void> result = addressOf.cast<Void>();
    _wrapper.value = result;
    return _wrapper;
  }
}

class NSUInteger32x2 extends Struct {
  @Uint32()
  int i1, i2;

  factory NSUInteger32x2(int i1, int i2) => allocate<NSUInteger32x2>().ref
    ..i1 = i1
    ..i2 = i2;

  factory NSUInteger32x2.fromPointer(Pointer<NSUInteger32x2> ptr) {
    return ptr.ref;
  }
}

class NSUInteger64x2 extends Struct {
  @Uint64()
  int i1, i2;

  factory NSUInteger64x2(int i1, int i2) => allocate<NSUInteger64x2>().ref
    ..i1 = i1
    ..i2 = i2;

  factory NSUInteger64x2.fromPointer(Pointer<NSUInteger64x2> ptr) {
    return ptr.ref;
  }
}

class NSUIntegerx2Wrapper extends NativeStruct {
  NSUInteger32x2 _value32;
  NSUInteger64x2 _value64;

  bool get _is64bit => LP64 || NS_BUILD_32_LIKE_64;

  int get i1 => _is64bit ? _value64.i1 : _value32.i1;
  set i1(int i1) {
    if (_is64bit) {
      _value64.i1 = i1;
    } else {
      _value32.i1 = i1;
    }
  }

  int get i2 => _is64bit ? _value64.i2 : _value32.i2;
  set i2(int i2) {
    if (_is64bit) {
      _value64.i2 = i2;
    } else {
      _value32.i2 = i2;
    }
  }

  NSUIntegerx2Wrapper(int i1, int i2) {
    if (_is64bit) {
      _value64 = NSUInteger64x2(i1, i2);
    } else {
      _value32 = NSUInteger32x2(i1, i2);
    }
    wrapper;
  }

  Pointer get addressOf => _is64bit ? _value64.addressOf : _value32.addressOf;

  NSUIntegerx2Wrapper.fromPointer(Pointer<Void> ptr) {
    if (_is64bit) {
      _value64 = NSUInteger64x2.fromPointer(ptr.cast());
    } else {
      _value32 = NSUInteger32x2.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    return i1 == other.i1 && i2 == other.i2;
  }

  @override
  int get hashCode => i1.hashCode ^ i2.hashCode;

  @override
  String toString() {
    return '$runtimeType=($i1, $i2)';
  }
}

class CGFloat32x2 extends Struct {
  @Float()
  double d1, d2;

  factory CGFloat32x2(double d1, double d2) => allocate<CGFloat32x2>().ref
    ..d1 = d1
    ..d2 = d2;

  factory CGFloat32x2.fromPointer(Pointer<CGFloat32x2> ptr) {
    return ptr.ref;
  }
}

class CGFloat64x2 extends Struct {
  @Double()
  double d1, d2;

  factory CGFloat64x2(double d1, double d2) => allocate<CGFloat64x2>().ref
    ..d1 = d1
    ..d2 = d2;

  factory CGFloat64x2.fromPointer(Pointer<CGFloat64x2> ptr) {
    return ptr.ref;
  }
}

class CGFloatx2Wrapper extends NativeStruct {
  CGFloat32x2 _value32;
  CGFloat64x2 _value64;

  double get d1 => LP64 ? _value64.d1 : _value32.d1;
  set d1(double d1) {
    if (LP64) {
      _value64.d1 = d1;
    } else {
      _value32.d1 = d1;
    }
  }

  double get d2 => LP64 ? _value64.d2 : _value32.d2;
  set d2(double d2) {
    if (LP64) {
      _value64.d2 = d2;
    } else {
      _value32.d2 = d2;
    }
  }

  CGFloatx2Wrapper(double d1, double d2) {
    if (LP64) {
      _value64 = CGFloat64x2(d1, d2);
    } else {
      _value32 = CGFloat32x2(d1, d2);
    }
    wrapper;
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  CGFloatx2Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = CGFloat64x2.fromPointer(ptr.cast());
    } else {
      _value32 = CGFloat32x2.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    return d1 == other.d1 && d2 == other.d2;
  }

  @override
  int get hashCode => d1.hashCode ^ d2.hashCode;

  @override
  String toString() {
    return '$runtimeType=($d1, $d2)';
  }
}

class CGFloat32x4 extends Struct {
  @Float()
  double d1, d2, d3, d4;

  factory CGFloat32x4(double d1, double d2, double d3, double d4) =>
      allocate<CGFloat32x4>().ref
        ..d1 = d1
        ..d2 = d2
        ..d3 = d3
        ..d4 = d4;

  factory CGFloat32x4.fromPointer(Pointer<CGFloat32x4> ptr) {
    return ptr.ref;
  }
}

class CGFloat64x4 extends Struct {
  @Double()
  double d1, d2, d3, d4;

  factory CGFloat64x4(double d1, double d2, double d3, double d4) =>
      allocate<CGFloat64x4>().ref
        ..d1 = d1
        ..d2 = d2
        ..d3 = d3
        ..d4 = d4;

  factory CGFloat64x4.fromPointer(Pointer<CGFloat64x4> ptr) {
    return ptr.ref;
  }
}

class CGFloatx4Wrapper extends NativeStruct {
  CGFloat32x4 _value32;
  CGFloat64x4 _value64;

  double get d1 => LP64 ? _value64.d1 : _value32.d1;
  set d1(double d1) {
    if (LP64) {
      _value64.d1 = d1;
    } else {
      _value32.d1 = d1;
    }
  }

  double get d2 => LP64 ? _value64.d2 : _value32.d2;
  set d2(double d2) {
    if (LP64) {
      _value64.d2 = d2;
    } else {
      _value32.d2 = d2;
    }
  }

  double get d3 => LP64 ? _value64.d3 : _value32.d3;
  set d3(double d3) {
    if (LP64) {
      _value64.d3 = d3;
    } else {
      _value32.d3 = d3;
    }
  }

  double get d4 => LP64 ? _value64.d4 : _value32.d4;
  set d4(double d4) {
    if (LP64) {
      _value64.d4 = d4;
    } else {
      _value32.d4 = d4;
    }
  }

  CGFloatx4Wrapper(double d1, double d2, double d3, double d4) {
    if (LP64) {
      _value64 = CGFloat64x4(d1, d2, d3, d4);
    } else {
      _value32 = CGFloat32x4(d1, d2, d3, d4);
    }
    wrapper;
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  CGFloatx4Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = CGFloat64x4.fromPointer(ptr.cast());
    } else {
      _value32 = CGFloat32x4.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    return d1 == other.d1 && d2 == other.d2 && d3 == other.d3 && d4 == other.d4;
  }

  @override
  int get hashCode => d1.hashCode ^ d2.hashCode ^ d3.hashCode ^ d4.hashCode;

  @override
  String toString() {
    return '$runtimeType=($d1, $d2, $d3, $d4)';
  }
}

class CGFloat32x6 extends Struct {
  @Float()
  double d1, d2, d3, d4, d5, d6;

  factory CGFloat32x6(
          double d1, double d2, double d3, double d4, double d5, double d6) =>
      allocate<CGFloat32x6>().ref
        ..d1 = d1
        ..d2 = d2
        ..d3 = d3
        ..d4 = d4
        ..d5 = d5
        ..d6 = d6;

  factory CGFloat32x6.fromPointer(Pointer<CGFloat32x6> ptr) {
    return ptr.ref;
  }
}

class CGFloat64x6 extends Struct {
  @Double()
  double d1, d2, d3, d4, d5, d6;

  factory CGFloat64x6(
          double d1, double d2, double d3, double d4, double d5, double d6) =>
      allocate<CGFloat64x6>().ref
        ..d1 = d1
        ..d2 = d2
        ..d3 = d3
        ..d4 = d4
        ..d5 = d5
        ..d6 = d6;

  factory CGFloat64x6.fromPointer(Pointer<CGFloat64x6> ptr) {
    return ptr.ref;
  }
}

class CGFloatx6Wrapper extends NativeStruct {
  CGFloat32x6 _value32;
  CGFloat64x6 _value64;

  double get d1 => LP64 ? _value64.d1 : _value32.d1;
  set d1(double d1) {
    if (LP64) {
      _value64.d1 = d1;
    } else {
      _value32.d1 = d1;
    }
  }

  double get d2 => LP64 ? _value64.d2 : _value32.d2;
  set d2(double d2) {
    if (LP64) {
      _value64.d2 = d2;
    } else {
      _value32.d2 = d2;
    }
  }

  double get d3 => LP64 ? _value64.d3 : _value32.d3;
  set d3(double d3) {
    if (LP64) {
      _value64.d3 = d3;
    } else {
      _value32.d3 = d3;
    }
  }

  double get d4 => LP64 ? _value64.d4 : _value32.d4;
  set d4(double d4) {
    if (LP64) {
      _value64.d4 = d4;
    } else {
      _value32.d4 = d4;
    }
  }

  double get d5 => LP64 ? _value64.d5 : _value32.d5;
  set d5(double d5) {
    if (LP64) {
      _value64.d5 = d5;
    } else {
      _value32.d5 = d5;
    }
  }

  double get d6 => LP64 ? _value64.d6 : _value32.d6;
  set d6(double d6) {
    if (LP64) {
      _value64.d6 = d6;
    } else {
      _value32.d6 = d6;
    }
  }

  CGFloatx6Wrapper(
      double d1, double d2, double d3, double d4, double d5, double d6) {
    if (LP64) {
      _value64 = CGFloat64x6(d1, d2, d3, d4, d5, d6);
    } else {
      _value32 = CGFloat32x6(d1, d2, d3, d4, d5, d6);
    }
    wrapper;
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  CGFloatx6Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = CGFloat64x6.fromPointer(ptr.cast());
    } else {
      _value32 = CGFloat32x6.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    return d1 == other.d1 &&
        d2 == other.d2 &&
        d3 == other.d3 &&
        d4 == other.d4 &&
        d5 == other.d5 &&
        d6 == other.d6;
  }

  @override
  int get hashCode =>
      d1.hashCode ^
      d2.hashCode ^
      d3.hashCode ^
      d4.hashCode ^
      d5.hashCode ^
      d6.hashCode;

  @override
  String toString() {
    return '$runtimeType=($d1, $d2, $d3, $d4, $d5, $d6)';
  }
}

class CGFloat32x16 extends Struct {
  @Float()
  double d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16;

  factory CGFloat32x16(
          double d1,
          double d2,
          double d3,
          double d4,
          double d5,
          double d6,
          double d7,
          double d8,
          double d9,
          double d10,
          double d11,
          double d12,
          double d13,
          double d14,
          double d15,
          double d16) =>
      allocate<CGFloat32x16>().ref
        ..d1 = d1
        ..d2 = d2
        ..d3 = d3
        ..d4 = d4
        ..d5 = d5
        ..d6 = d6
        ..d7 = d7
        ..d8 = d8
        ..d9 = d9
        ..d10 = d10
        ..d11 = d11
        ..d12 = d12
        ..d13 = d13
        ..d14 = d14
        ..d15 = d15
        ..d16 = d16;

  factory CGFloat32x16.fromPointer(Pointer<CGFloat32x16> ptr) {
    return ptr.ref;
  }
}

class CGFloat64x16 extends Struct {
  @Double()
  double d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16;

  factory CGFloat64x16(
          double d1,
          double d2,
          double d3,
          double d4,
          double d5,
          double d6,
          double d7,
          double d8,
          double d9,
          double d10,
          double d11,
          double d12,
          double d13,
          double d14,
          double d15,
          double d16) =>
      allocate<CGFloat64x16>().ref
        ..d1 = d1
        ..d2 = d2
        ..d3 = d3
        ..d4 = d4
        ..d5 = d5
        ..d6 = d6
        ..d7 = d7
        ..d8 = d8
        ..d9 = d9
        ..d10 = d10
        ..d11 = d11
        ..d12 = d12
        ..d13 = d13
        ..d14 = d14
        ..d15 = d15
        ..d16 = d16;

  factory CGFloat64x16.fromPointer(Pointer<CGFloat64x16> ptr) {
    return ptr.ref;
  }
}

class CGFloatx16Wrapper extends NativeStruct {
  CGFloat32x16 _value32;
  CGFloat64x16 _value64;

  double get d1 => LP64 ? _value64.d1 : _value32.d1;
  set d1(double d1) {
    if (LP64) {
      _value64.d1 = d1;
    } else {
      _value32.d1 = d1;
    }
  }

  double get d2 => LP64 ? _value64.d2 : _value32.d2;
  set d2(double d2) {
    if (LP64) {
      _value64.d2 = d2;
    } else {
      _value32.d2 = d2;
    }
  }

  double get d3 => LP64 ? _value64.d3 : _value32.d3;
  set d3(double d3) {
    if (LP64) {
      _value64.d3 = d3;
    } else {
      _value32.d3 = d3;
    }
  }

  double get d4 => LP64 ? _value64.d4 : _value32.d4;
  set d4(double d4) {
    if (LP64) {
      _value64.d4 = d4;
    } else {
      _value32.d4 = d4;
    }
  }

  double get d5 => LP64 ? _value64.d5 : _value32.d5;
  set d5(double d5) {
    if (LP64) {
      _value64.d5 = d5;
    } else {
      _value32.d5 = d5;
    }
  }

  double get d6 => LP64 ? _value64.d6 : _value32.d6;
  set d6(double d6) {
    if (LP64) {
      _value64.d6 = d6;
    } else {
      _value32.d6 = d6;
    }
  }

  double get d7 => LP64 ? _value64.d7 : _value32.d7;
  set d7(double d7) {
    if (LP64) {
      _value64.d7 = d7;
    } else {
      _value32.d7 = d7;
    }
  }

  double get d8 => LP64 ? _value64.d8 : _value32.d8;
  set d8(double d8) {
    if (LP64) {
      _value64.d8 = d8;
    } else {
      _value32.d8 = d8;
    }
  }

  double get d9 => LP64 ? _value64.d9 : _value32.d9;
  set d9(double d9) {
    if (LP64) {
      _value64.d9 = d9;
    } else {
      _value32.d9 = d9;
    }
  }

  double get d10 => LP64 ? _value64.d10 : _value32.d10;
  set d10(double d10) {
    if (LP64) {
      _value64.d10 = d10;
    } else {
      _value32.d10 = d10;
    }
  }

  double get d11 => LP64 ? _value64.d11 : _value32.d11;
  set d11(double d11) {
    if (LP64) {
      _value64.d11 = d11;
    } else {
      _value32.d11 = d11;
    }
  }

  double get d12 => LP64 ? _value64.d12 : _value32.d12;
  set d12(double d12) {
    if (LP64) {
      _value64.d12 = d12;
    } else {
      _value32.d12 = d12;
    }
  }

  double get d13 => LP64 ? _value64.d13 : _value32.d13;
  set d13(double d13) {
    if (LP64) {
      _value64.d13 = d13;
    } else {
      _value32.d13 = d13;
    }
  }

  double get d14 => LP64 ? _value64.d14 : _value32.d14;
  set d14(double d14) {
    if (LP64) {
      _value64.d14 = d14;
    } else {
      _value32.d14 = d14;
    }
  }

  double get d15 => LP64 ? _value64.d15 : _value32.d15;
  set d15(double d15) {
    if (LP64) {
      _value64.d15 = d15;
    } else {
      _value32.d15 = d15;
    }
  }

  double get d16 => LP64 ? _value64.d16 : _value32.d16;
  set d16(double d16) {
    if (LP64) {
      _value64.d16 = d16;
    } else {
      _value32.d16 = d16;
    }
  }

  CGFloatx16Wrapper(
      double d1,
      double d2,
      double d3,
      double d4,
      double d5,
      double d6,
      double d7,
      double d8,
      double d9,
      double d10,
      double d11,
      double d12,
      double d13,
      double d14,
      double d15,
      double d16) {
    if (LP64) {
      _value64 = CGFloat64x16(d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12,
          d13, d14, d15, d16);
    } else {
      _value32 = CGFloat32x16(d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12,
          d13, d14, d15, d16);
    }
    wrapper;
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  CGFloatx16Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = CGFloat64x16.fromPointer(ptr.cast());
    } else {
      _value32 = CGFloat32x16.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    return d1 == other.d1 &&
        d2 == other.d2 &&
        d3 == other.d3 &&
        d4 == other.d4 &&
        d5 == other.d5 &&
        d6 == other.d6 &&
        d7 == other.d7 &&
        d8 == other.d8 &&
        d9 == other.d9 &&
        d10 == other.d10 &&
        d11 == other.d11 &&
        d12 == other.d12 &&
        d13 == other.d13 &&
        d14 == other.d14 &&
        d15 == other.d15 &&
        d16 == other.d16;
  }

  @override
  int get hashCode =>
      d1.hashCode ^
      d2.hashCode ^
      d3.hashCode ^
      d4.hashCode ^
      d5.hashCode ^
      d6.hashCode ^
      d7.hashCode ^
      d8.hashCode ^
      d9.hashCode ^
      d10.hashCode ^
      d11.hashCode ^
      d12.hashCode ^
      d13.hashCode ^
      d14.hashCode ^
      d15.hashCode ^
      d16.hashCode;

  @override
  String toString() {
    return '$runtimeType=($d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $d10, $d11, $d12, $d13, $d14, $d15, $d16)';
  }
}
