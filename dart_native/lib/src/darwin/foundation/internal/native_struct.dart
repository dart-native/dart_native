import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/darwin/common/precompile_macro.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/darwin/common/pointer_wrapper.dart';

abstract class NativeStruct {
  Pointer get addressOf;

  /// Alias for box/unbox [NSValue]
  /// See [valueWithStruct]
  String get aliasForNSValue => runtimeType.toString();
  late PointerWrapper wrapper = PointerWrapper(addressOf.cast<Void>());
}

class NSUInteger32x2 extends Struct {
  @Uint32()
  external int i1, i2;

  static Pointer<NSUInteger32x2> callocPointer(int i1, int i2) =>
      calloc<NSUInteger32x2>()
        ..ref.i1 = i1
        ..ref.i2 = i2;
}

class NSUInteger64x2 extends Struct {
  @Uint64()
  external int i1, i2;

  static Pointer<NSUInteger64x2> callocPointer(int i1, int i2) =>
      calloc<NSUInteger64x2>()
        ..ref.i1 = i1
        ..ref.i2 = i2;
}

abstract class NSUIntegerx2Wrapper extends NativeStruct {
  late Pointer<NSUInteger32x2> _ptr32;
  late Pointer<NSUInteger64x2> _ptr64;

  bool get _is64bit => LP64 || NS_BUILD_32_LIKE_64;

  int get i1 => _is64bit ? _ptr64.ref.i1 : _ptr32.ref.i1;
  set i1(int i1) {
    if (_is64bit) {
      _ptr64.ref.i1 = i1;
    } else {
      _ptr32.ref.i1 = i1;
    }
  }

  int get i2 => _is64bit ? _ptr64.ref.i2 : _ptr32.ref.i2;
  set i2(int i2) {
    if (_is64bit) {
      _ptr64.ref.i2 = i2;
    } else {
      _ptr32.ref.i2 = i2;
    }
  }

  NSUIntegerx2Wrapper(int i1, int i2) {
    if (_is64bit) {
      _ptr64 = NSUInteger64x2.callocPointer(i1, i2);
    } else {
      _ptr32 = NSUInteger32x2.callocPointer(i1, i2);
    }
  }

  @override
  Pointer get addressOf => _is64bit ? _ptr64 : _ptr32;

  NSUIntegerx2Wrapper.fromPointer(Pointer<Void> ptr) {
    if (_is64bit) {
      _ptr64 = ptr.cast();
    } else {
      _ptr32 = ptr.cast();
    }
    wrapper;
  }

  @override
  bool operator ==(other) {
    if (other is NSUIntegerx2Wrapper) return i1 == other.i1 && i2 == other.i2;
    return false;
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
  external double d1, d2;

  static Pointer<CGFloat32x2> callocPointer(double d1, double d2) =>
      calloc<CGFloat32x2>()
        ..ref.d1 = d1
        ..ref.d2 = d2;
}

class CGFloat64x2 extends Struct {
  @Double()
  external double d1, d2;

  static Pointer<CGFloat64x2> callocPointer(double d1, double d2) =>
      calloc<CGFloat64x2>()
        ..ref.d1 = d1
        ..ref.d2 = d2;
}

abstract class CGFloatx2Wrapper extends NativeStruct {
  late Pointer<CGFloat32x2> _ptr32;
  late Pointer<CGFloat64x2> _ptr64;

  double get d1 => LP64 ? _ptr64.ref.d1 : _ptr32.ref.d1;
  set d1(double d1) {
    if (LP64) {
      _ptr64.ref.d1 = d1;
    } else {
      _ptr32.ref.d1 = d1;
    }
  }

  double get d2 => LP64 ? _ptr64.ref.d2 : _ptr32.ref.d2;
  set d2(double d2) {
    if (LP64) {
      _ptr64.ref.d2 = d2;
    } else {
      _ptr32.ref.d2 = d2;
    }
  }

  CGFloatx2Wrapper(double d1, double d2) {
    if (LP64) {
      _ptr64 = CGFloat64x2.callocPointer(d1, d2);
    } else {
      _ptr32 = CGFloat32x2.callocPointer(d1, d2);
    }
  }

  @override
  Pointer get addressOf => LP64 ? _ptr64 : _ptr32;

  CGFloatx2Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _ptr64 = ptr.cast();
    } else {
      _ptr32 = ptr.cast();
    }
    wrapper;
  }

  @override
  bool operator ==(other) {
    if (other is CGFloatx2Wrapper) return d1 == other.d1 && d2 == other.d2;
    return false;
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
  external double d1, d2, d3, d4;

  static Pointer<CGFloat32x4> callocPointer(
          double d1, double d2, double d3, double d4) =>
      calloc<CGFloat32x4>()
        ..ref.d1 = d1
        ..ref.d2 = d2
        ..ref.d3 = d3
        ..ref.d4 = d4;
}

class CGFloat64x4 extends Struct {
  @Double()
  external double d1, d2, d3, d4;

  static Pointer<CGFloat64x4> callocPointer(
          double d1, double d2, double d3, double d4) =>
      calloc<CGFloat64x4>()
        ..ref.d1 = d1
        ..ref.d2 = d2
        ..ref.d3 = d3
        ..ref.d4 = d4;
}

abstract class CGFloatx4Wrapper extends NativeStruct {
  late Pointer<CGFloat32x4> _ptr32;
  late Pointer<CGFloat64x4> _ptr64;

  double get d1 => LP64 ? _ptr64.ref.d1 : _ptr32.ref.d1;
  set d1(double d1) {
    if (LP64) {
      _ptr64.ref.d1 = d1;
    } else {
      _ptr32.ref.d1 = d1;
    }
  }

  double get d2 => LP64 ? _ptr64.ref.d2 : _ptr32.ref.d2;
  set d2(double d2) {
    if (LP64) {
      _ptr64.ref.d2 = d2;
    } else {
      _ptr32.ref.d2 = d2;
    }
  }

  double get d3 => LP64 ? _ptr64.ref.d3 : _ptr32.ref.d3;
  set d3(double d3) {
    if (LP64) {
      _ptr64.ref.d3 = d3;
    } else {
      _ptr32.ref.d3 = d3;
    }
  }

  double get d4 => LP64 ? _ptr64.ref.d4 : _ptr32.ref.d4;
  set d4(double d4) {
    if (LP64) {
      _ptr64.ref.d4 = d4;
    } else {
      _ptr32.ref.d4 = d4;
    }
  }

  CGFloatx4Wrapper(double d1, double d2, double d3, double d4) {
    if (LP64) {
      _ptr64 = CGFloat64x4.callocPointer(d1, d2, d3, d4);
    } else {
      _ptr32 = CGFloat32x4.callocPointer(d1, d2, d3, d4);
    }
  }

  @override
  Pointer get addressOf => LP64 ? _ptr64 : _ptr32;

  CGFloatx4Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _ptr64 = ptr.cast();
    } else {
      _ptr32 = ptr.cast();
    }
    wrapper;
  }

  @override
  bool operator ==(other) {
    if (other is CGFloatx4Wrapper) {
      return d1 == other.d1 &&
          d2 == other.d2 &&
          d3 == other.d3 &&
          d4 == other.d4;
    }
    return false;
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
  external double d1, d2, d3, d4, d5, d6;

  static Pointer<CGFloat32x6> callocPointer(
          double d1, double d2, double d3, double d4, double d5, double d6) =>
      calloc<CGFloat32x6>()
        ..ref.d1 = d1
        ..ref.d2 = d2
        ..ref.d3 = d3
        ..ref.d4 = d4
        ..ref.d5 = d5
        ..ref.d6 = d6;
}

class CGFloat64x6 extends Struct {
  @Double()
  external double d1, d2, d3, d4, d5, d6;

  static Pointer<CGFloat64x6> callocPointer(
          double d1, double d2, double d3, double d4, double d5, double d6) =>
      calloc<CGFloat64x6>()
        ..ref.d1 = d1
        ..ref.d2 = d2
        ..ref.d3 = d3
        ..ref.d4 = d4
        ..ref.d5 = d5
        ..ref.d6 = d6;
}

abstract class CGFloatx6Wrapper extends NativeStruct {
  late Pointer<CGFloat32x6> _ptr32;
  late Pointer<CGFloat64x6> _ptr64;

  double get d1 => LP64 ? _ptr64.ref.d1 : _ptr32.ref.d1;
  set d1(double d1) {
    if (LP64) {
      _ptr64.ref.d1 = d1;
    } else {
      _ptr32.ref.d1 = d1;
    }
  }

  double get d2 => LP64 ? _ptr64.ref.d2 : _ptr32.ref.d2;
  set d2(double d2) {
    if (LP64) {
      _ptr64.ref.d2 = d2;
    } else {
      _ptr32.ref.d2 = d2;
    }
  }

  double get d3 => LP64 ? _ptr64.ref.d3 : _ptr32.ref.d3;
  set d3(double d3) {
    if (LP64) {
      _ptr64.ref.d3 = d3;
    } else {
      _ptr32.ref.d3 = d3;
    }
  }

  double get d4 => LP64 ? _ptr64.ref.d4 : _ptr32.ref.d4;
  set d4(double d4) {
    if (LP64) {
      _ptr64.ref.d4 = d4;
    } else {
      _ptr32.ref.d4 = d4;
    }
  }

  double get d5 => LP64 ? _ptr64.ref.d5 : _ptr32.ref.d5;
  set d5(double d5) {
    if (LP64) {
      _ptr64.ref.d5 = d5;
    } else {
      _ptr32.ref.d5 = d5;
    }
  }

  double get d6 => LP64 ? _ptr64.ref.d6 : _ptr32.ref.d6;
  set d6(double d6) {
    if (LP64) {
      _ptr64.ref.d6 = d6;
    } else {
      _ptr32.ref.d6 = d6;
    }
  }

  CGFloatx6Wrapper(
      double d1, double d2, double d3, double d4, double d5, double d6) {
    if (LP64) {
      _ptr64 = CGFloat64x6.callocPointer(d1, d2, d3, d4, d5, d6);
    } else {
      _ptr32 = CGFloat32x6.callocPointer(d1, d2, d3, d4, d5, d6);
    }
  }

  @override
  Pointer get addressOf => LP64 ? _ptr64 : _ptr32;

  CGFloatx6Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _ptr64 = ptr.cast();
    } else {
      _ptr32 = ptr.cast();
    }
    wrapper;
  }

  @override
  bool operator ==(other) {
    if (other is CGFloatx6Wrapper) {
      return d1 == other.d1 &&
          d2 == other.d2 &&
          d3 == other.d3 &&
          d4 == other.d4 &&
          d5 == other.d5 &&
          d6 == other.d6;
    }
    return false;
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
  external double d1,
      d2,
      d3,
      d4,
      d5,
      d6,
      d7,
      d8,
      d9,
      d10,
      d11,
      d12,
      d13,
      d14,
      d15,
      d16;

  static Pointer<CGFloat32x16> callocPointer(
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
      calloc<CGFloat32x16>()
        ..ref.d1 = d1
        ..ref.d2 = d2
        ..ref.d3 = d3
        ..ref.d4 = d4
        ..ref.d5 = d5
        ..ref.d6 = d6
        ..ref.d7 = d7
        ..ref.d8 = d8
        ..ref.d9 = d9
        ..ref.d10 = d10
        ..ref.d11 = d11
        ..ref.d12 = d12
        ..ref.d13 = d13
        ..ref.d14 = d14
        ..ref.d15 = d15
        ..ref.d16 = d16;
}

class CGFloat64x16 extends Struct {
  @Double()
  external double d1,
      d2,
      d3,
      d4,
      d5,
      d6,
      d7,
      d8,
      d9,
      d10,
      d11,
      d12,
      d13,
      d14,
      d15,
      d16;

  static Pointer<CGFloat64x16> callocPointer(
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
      calloc<CGFloat64x16>()
        ..ref.d1 = d1
        ..ref.d2 = d2
        ..ref.d3 = d3
        ..ref.d4 = d4
        ..ref.d5 = d5
        ..ref.d6 = d6
        ..ref.d7 = d7
        ..ref.d8 = d8
        ..ref.d9 = d9
        ..ref.d10 = d10
        ..ref.d11 = d11
        ..ref.d12 = d12
        ..ref.d13 = d13
        ..ref.d14 = d14
        ..ref.d15 = d15
        ..ref.d16 = d16;
}

abstract class CGFloatx16Wrapper extends NativeStruct {
  late Pointer<CGFloat32x16> _ptr32;
  late Pointer<CGFloat64x16> _ptr64;

  double get d1 => LP64 ? _ptr64.ref.d1 : _ptr32.ref.d1;
  set d1(double d1) {
    if (LP64) {
      _ptr64.ref.d1 = d1;
    } else {
      _ptr32.ref.d1 = d1;
    }
  }

  double get d2 => LP64 ? _ptr64.ref.d2 : _ptr32.ref.d2;
  set d2(double d2) {
    if (LP64) {
      _ptr64.ref.d2 = d2;
    } else {
      _ptr32.ref.d2 = d2;
    }
  }

  double get d3 => LP64 ? _ptr64.ref.d3 : _ptr32.ref.d3;
  set d3(double d3) {
    if (LP64) {
      _ptr64.ref.d3 = d3;
    } else {
      _ptr32.ref.d3 = d3;
    }
  }

  double get d4 => LP64 ? _ptr64.ref.d4 : _ptr32.ref.d4;
  set d4(double d4) {
    if (LP64) {
      _ptr64.ref.d4 = d4;
    } else {
      _ptr32.ref.d4 = d4;
    }
  }

  double get d5 => LP64 ? _ptr64.ref.d5 : _ptr32.ref.d5;
  set d5(double d5) {
    if (LP64) {
      _ptr64.ref.d5 = d5;
    } else {
      _ptr32.ref.d5 = d5;
    }
  }

  double get d6 => LP64 ? _ptr64.ref.d6 : _ptr32.ref.d6;
  set d6(double d6) {
    if (LP64) {
      _ptr64.ref.d6 = d6;
    } else {
      _ptr32.ref.d6 = d6;
    }
  }

  double get d7 => LP64 ? _ptr64.ref.d7 : _ptr32.ref.d7;
  set d7(double d7) {
    if (LP64) {
      _ptr64.ref.d7 = d7;
    } else {
      _ptr32.ref.d7 = d7;
    }
  }

  double get d8 => LP64 ? _ptr64.ref.d8 : _ptr32.ref.d8;
  set d8(double d8) {
    if (LP64) {
      _ptr64.ref.d8 = d8;
    } else {
      _ptr32.ref.d8 = d8;
    }
  }

  double get d9 => LP64 ? _ptr64.ref.d9 : _ptr32.ref.d9;
  set d9(double d9) {
    if (LP64) {
      _ptr64.ref.d9 = d9;
    } else {
      _ptr32.ref.d9 = d9;
    }
  }

  double get d10 => LP64 ? _ptr64.ref.d10 : _ptr32.ref.d10;
  set d10(double d10) {
    if (LP64) {
      _ptr64.ref.d10 = d10;
    } else {
      _ptr32.ref.d10 = d10;
    }
  }

  double get d11 => LP64 ? _ptr64.ref.d11 : _ptr32.ref.d11;
  set d11(double d11) {
    if (LP64) {
      _ptr64.ref.d11 = d11;
    } else {
      _ptr32.ref.d11 = d11;
    }
  }

  double get d12 => LP64 ? _ptr64.ref.d12 : _ptr32.ref.d12;
  set d12(double d12) {
    if (LP64) {
      _ptr64.ref.d12 = d12;
    } else {
      _ptr32.ref.d12 = d12;
    }
  }

  double get d13 => LP64 ? _ptr64.ref.d13 : _ptr32.ref.d13;
  set d13(double d13) {
    if (LP64) {
      _ptr64.ref.d13 = d13;
    } else {
      _ptr32.ref.d13 = d13;
    }
  }

  double get d14 => LP64 ? _ptr64.ref.d14 : _ptr32.ref.d14;
  set d14(double d14) {
    if (LP64) {
      _ptr64.ref.d14 = d14;
    } else {
      _ptr32.ref.d14 = d14;
    }
  }

  double get d15 => LP64 ? _ptr64.ref.d15 : _ptr32.ref.d15;
  set d15(double d15) {
    if (LP64) {
      _ptr64.ref.d15 = d15;
    } else {
      _ptr32.ref.d15 = d15;
    }
  }

  double get d16 => LP64 ? _ptr64.ref.d16 : _ptr32.ref.d16;
  set d16(double d16) {
    if (LP64) {
      _ptr64.ref.d16 = d16;
    } else {
      _ptr32.ref.d16 = d16;
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
      _ptr64 = CGFloat64x16.callocPointer(d1, d2, d3, d4, d5, d6, d7, d8, d9,
          d10, d11, d12, d13, d14, d15, d16);
    } else {
      _ptr32 = CGFloat32x16.callocPointer(d1, d2, d3, d4, d5, d6, d7, d8, d9,
          d10, d11, d12, d13, d14, d15, d16);
    }
  }

  @override
  Pointer get addressOf => LP64 ? _ptr64 : _ptr32;

  CGFloatx16Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _ptr64 = ptr.cast();
    } else {
      _ptr32 = ptr.cast();
    }
    wrapper;
  }

  @override
  bool operator ==(other) {
    if (other is CGFloatx16Wrapper) {
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
    return false;
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
