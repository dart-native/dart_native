import 'dart:ffi';

import 'package:dart_native/src/ios/common/precompile_macro.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/ios/common/pointer_wrapper.dart';

abstract class NativeStruct {
  Pointer get addressOf;

  PointerWrapper _wrapper;
  PointerWrapper get wrapper {
    if (_wrapper == null) {
      _wrapper = PointerWrapper(dealloc);
    }
    Pointer<Void> result = addressOf.cast<Void>();
    _wrapper.value = result;
    return _wrapper;
  }

  NativeStruct retain() {
    wrapper.retain();
    return this;
  }

  release() => wrapper.release();

  dealloc() {}
}

class NSUInteger32x2 extends Struct {
  @Uint32()
  int a;
  @Uint32()
  int b;

  factory NSUInteger32x2(int a, int b) => allocate<NSUInteger32x2>().ref
    ..a = a
    ..b = b;

  factory NSUInteger32x2.fromPointer(Pointer<NSUInteger32x2> ptr) {
    return ptr.ref;
  }
}

class NSUInteger64x2 extends Struct {
  @Uint64()
  int a;
  @Uint64()
  int b;

  factory NSUInteger64x2(int a, int b) => allocate<NSUInteger64x2>().ref
    ..a = a
    ..b = b;

  factory NSUInteger64x2.fromPointer(Pointer<NSUInteger64x2> ptr) {
    return ptr.ref;
  }
}

class NSUIntegerx2Wrapper extends NativeStruct {
  NSUInteger32x2 _value32;
  NSUInteger64x2 _value64;

  bool get _is64bit => LP64 || NS_BUILD_32_LIKE_64;

  int get a => _is64bit ? _value64.a : _value32.a;
  set a(int a) {
    if (_is64bit) {
      _value64.a = a;
    } else {
      _value32.a = a;
    }
  }

  int get b => _is64bit ? _value64.b : _value32.b;
  set b(int b) {
    if (_is64bit) {
      _value64.b = b;
    } else {
      _value32.b = b;
    }
  }

  NSUIntegerx2Wrapper(int a, int b) {
    if (_is64bit) {
      _value64 = NSUInteger64x2(a, b);
    } else {
      _value32 = NSUInteger32x2(a, b);
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
    if (other == null) return false;
    return a == other.a && b == other.b;
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode;

  @override
  String toString() {
    return '$runtimeType=($a, $b)';
  }
}

class CGFloat32x2 extends Struct {
  @Float()
  double a;
  @Float()
  double b;

  factory CGFloat32x2(double a, double b) => allocate<CGFloat32x2>().ref
    ..a = a
    ..b = b;

  factory CGFloat32x2.fromPointer(Pointer<CGFloat32x2> ptr) {
    return ptr.ref;
  }
}

class CGFloat64x2 extends Struct {
  @Double()
  double a;
  @Double()
  double b;

  factory CGFloat64x2(double a, double b) => allocate<CGFloat64x2>().ref
    ..a = a
    ..b = b;

  factory CGFloat64x2.fromPointer(Pointer<CGFloat64x2> ptr) {
    return ptr.ref;
  }
}

class CGFloatx2Wrapper extends NativeStruct {
  CGFloat32x2 _value32;
  CGFloat64x2 _value64;

  double get a => LP64 ? _value64.a : _value32.a;
  set a(double a) {
    if (LP64) {
      _value64.a = a;
    } else {
      _value32.a = a;
    }
  }

  double get b => LP64 ? _value64.b : _value32.b;
  set b(double b) {
    if (LP64) {
      _value64.b = b;
    } else {
      _value32.b = b;
    }
  }

  CGFloatx2Wrapper(double a, double b) {
    if (LP64) {
      _value64 = CGFloat64x2(a, b);
    } else {
      _value32 = CGFloat32x2(a, b);
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
    if (other == null) return false;
    return a == other.a && b == other.b;
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode;

  @override
  String toString() {
    return '$runtimeType=($a, $b)';
  }
}

class CGFloat32x4 extends Struct {
  @Float()
  double a;
  @Float()
  double b;
  @Float()
  double c;
  @Float()
  double d;

  factory CGFloat32x4(double a, double b, double c, double d) =>
      allocate<CGFloat32x4>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory CGFloat32x4.fromPointer(Pointer<CGFloat32x4> ptr) {
    return ptr.ref;
  }
}

class CGFloat64x4 extends Struct {
  @Double()
  double a;
  @Double()
  double b;
  @Double()
  double c;
  @Double()
  double d;

  factory CGFloat64x4(double a, double b, double c, double d) =>
      allocate<CGFloat64x4>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory CGFloat64x4.fromPointer(Pointer<CGFloat64x4> ptr) {
    return ptr.ref;
  }
}

class CGFloatx4Wrapper extends NativeStruct {
  CGFloat32x4 _value32;
  CGFloat64x4 _value64;

  double get a => LP64 ? _value64.a : _value32.a;
  set a(double a) {
    if (LP64) {
      _value64.a = a;
    } else {
      _value32.a = a;
    }
  }

  double get b => LP64 ? _value64.b : _value32.b;
  set b(double b) {
    if (LP64) {
      _value64.b = b;
    } else {
      _value32.b = b;
    }
  }

  double get c => LP64 ? _value64.c : _value32.c;
  set c(double c) {
    if (LP64) {
      _value64.c = c;
    } else {
      _value32.c = c;
    }
  }

  double get d => LP64 ? _value64.d : _value32.d;
  set d(double d) {
    if (LP64) {
      _value64.d = d;
    } else {
      _value32.d = d;
    }
  }

  CGFloatx4Wrapper(double a, double b, double c, double d) {
    if (LP64) {
      _value64 = CGFloat64x4(a, b, c, d);
    } else {
      _value32 = CGFloat32x4(a, b, c, d);
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
    if (other == null) return false;
    return a == other.a && b == other.b && c == other.c && d == other.d;
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode ^ c.hashCode ^ d.hashCode;

  @override
  String toString() {
    return '$runtimeType=($a, $b, $c, $d)';
  }
}

class CGFloat32x6 extends Struct {
  @Float()
  double a;
  @Float()
  double b;
  @Float()
  double c;
  @Float()
  double d;
  @Float()
  double e;
  @Float()
  double f;

  factory CGFloat32x6(
          double a, double b, double c, double d, double e, double f) =>
      allocate<CGFloat32x6>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d
        ..e = e
        ..f = f;

  factory CGFloat32x6.fromPointer(Pointer<CGFloat32x6> ptr) {
    return ptr.ref;
  }
}

class CGFloat64x6 extends Struct {
  @Double()
  double a;
  @Double()
  double b;
  @Double()
  double c;
  @Double()
  double d;
  @Double()
  double e;
  @Double()
  double f;

  factory CGFloat64x6(
          double a, double b, double c, double d, double e, double f) =>
      allocate<CGFloat64x6>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d
        ..e = e
        ..f = f;

  factory CGFloat64x6.fromPointer(Pointer<CGFloat64x6> ptr) {
    return ptr.ref;
  }
}

class CGFloatx6Wrapper extends NativeStruct {
  CGFloat32x6 _value32;
  CGFloat64x6 _value64;

  double get a => LP64 ? _value64.a : _value32.a;
  set a(double a) {
    if (LP64) {
      _value64.a = a;
    } else {
      _value32.a = a;
    }
  }

  double get b => LP64 ? _value64.b : _value32.b;
  set b(double b) {
    if (LP64) {
      _value64.b = b;
    } else {
      _value32.b = b;
    }
  }

  double get c => LP64 ? _value64.c : _value32.c;
  set c(double c) {
    if (LP64) {
      _value64.c = c;
    } else {
      _value32.c = c;
    }
  }

  double get d => LP64 ? _value64.d : _value32.d;
  set d(double d) {
    if (LP64) {
      _value64.d = d;
    } else {
      _value32.d = d;
    }
  }

  double get e => LP64 ? _value64.e : _value32.e;
  set e(double e) {
    if (LP64) {
      _value64.e = e;
    } else {
      _value32.e = e;
    }
  }

  double get f => LP64 ? _value64.f : _value32.f;
  set f(double f) {
    if (LP64) {
      _value64.f = f;
    } else {
      _value32.f = f;
    }
  }

  CGFloatx6Wrapper(double a, double b, double c, double d, double e, double f) {
    if (LP64) {
      _value64 = CGFloat64x6(a, b, c, d, e, f);
    } else {
      _value32 = CGFloat32x6(a, b, c, d, e, f);
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
    if (other == null) return false;
    return a == other.a &&
        b == other.b &&
        c == other.c &&
        d == other.d &&
        e == other.e &&
        f == other.f;
  }

  @override
  int get hashCode =>
      a.hashCode ^
      b.hashCode ^
      c.hashCode ^
      d.hashCode ^
      e.hashCode ^
      f.hashCode;

  @override
  String toString() {
    return '$runtimeType=($a, $b, $c, $d, $e, $f)';
  }
}
