import 'dart:ffi';

import 'package:dart_objc/src/common/precompile_macro.dart';
import 'package:ffi/ffi.dart';

abstract class NativeStruct {}

class _NSUInteger32x2 extends Struct {
  @Uint32()
  int a;
  @Uint32()
  int b;

  factory _NSUInteger32x2(int a, int b) => allocate<_NSUInteger32x2>().ref
    ..a = a
    ..b = b;

  factory _NSUInteger32x2.fromPointer(Pointer<_NSUInteger32x2> ptr) {
    return ptr.ref;
  }
}

class _NSUInteger64x2 extends Struct {
  @Uint64()
  int a;
  @Uint64()
  int b;

  factory _NSUInteger64x2(int a, int b) => allocate<_NSUInteger64x2>().ref
    ..a = a
    ..b = b;

  factory _NSUInteger64x2.fromPointer(Pointer<_NSUInteger64x2> ptr) {
    return ptr.ref;
  }
}

class _NSUIntegerx2Wrapper extends NativeStruct {
  _NSUInteger32x2 _value32;
  _NSUInteger64x2 _value64;

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

  _NSUIntegerx2Wrapper(int a, int b) {
    if (_is64bit) {
      _value64 = _NSUInteger64x2(a, b);
    } else {
      _value32 = _NSUInteger32x2(a, b);
    }
  }

  Pointer get addressOf => _is64bit ? _value64.addressOf : _value32.addressOf;

  _NSUIntegerx2Wrapper.fromPointer(Pointer<Void> ptr) {
    if (_is64bit) {
      _value64 = _NSUInteger64x2.fromPointer(ptr.cast());
    } else {
      _value32 = _NSUInteger32x2.fromPointer(ptr.cast());
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

class NSRange extends _NSUIntegerx2Wrapper {
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

class _CGFloat32x2 extends Struct {
  @Float()
  double a;
  @Float()
  double b;

  factory _CGFloat32x2(double a, double b) => allocate<_CGFloat32x2>().ref
    ..a = a
    ..b = b;

  factory _CGFloat32x2.fromPointer(Pointer<_CGFloat32x2> ptr) {
    return ptr.ref;
  }
}

class _CGFloat64x2 extends Struct {
  @Double()
  double a;
  @Double()
  double b;

  factory _CGFloat64x2(double a, double b) => allocate<_CGFloat64x2>().ref
    ..a = a
    ..b = b;

  factory _CGFloat64x2.fromPointer(Pointer<_CGFloat64x2> ptr) {
    return ptr.ref;
  }
}

class _CGFloatx2Wrapper extends NativeStruct {
  _CGFloat32x2 _value32;
  _CGFloat64x2 _value64;

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

  _CGFloatx2Wrapper(double a, double b) {
    if (LP64) {
      _value64 = _CGFloat64x2(a, b);
    } else {
      _value32 = _CGFloat32x2(a, b);
    }
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  _CGFloatx2Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = _CGFloat64x2.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat32x2.fromPointer(ptr.cast());
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

class UIOffset extends _CGFloatx2Wrapper {
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

class CGSize extends _CGFloatx2Wrapper {
  double get width => a;
  set width(double width) {
    a = width;
  }

  double get height => b;
  set height(double height) {
    b = height;
  }

  CGSize(double width, double height) : super(width, height);
  CGSize.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class CGPoint extends _CGFloatx2Wrapper {
  double get x => a;
  set x(double x) {
    a = x;
  }

  double get y => b;
  set y(double y) {
    b = y;
  }

  CGPoint(double x, double y) : super(x, y);
  CGPoint.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class CGVector extends _CGFloatx2Wrapper {
  double get dx => a;
  set dx(double dx) {
    a = dx;
  }

  double get dy => b;
  set dy(double dy) {
    b = dy;
  }

  CGVector(double dx, double dy) : super(dx, dy);
  CGVector.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class _CGFloat32x4 extends Struct {
  @Float()
  double a;
  @Float()
  double b;
  @Float()
  double c;
  @Float()
  double d;

  factory _CGFloat32x4(double a, double b, double c, double d) =>
      allocate<_CGFloat32x4>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory _CGFloat32x4.fromPointer(Pointer<_CGFloat32x4> ptr) {
    return ptr.ref;
  }
}

class _CGFloat64x4 extends Struct {
  @Double()
  double a;
  @Double()
  double b;
  @Double()
  double c;
  @Double()
  double d;

  factory _CGFloat64x4(double a, double b, double c, double d) =>
      allocate<_CGFloat64x4>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory _CGFloat64x4.fromPointer(Pointer<_CGFloat64x4> ptr) {
    return ptr.ref;
  }
}

class _CGFloatx4Wrapper extends NativeStruct {
  _CGFloat32x4 _value32;
  _CGFloat64x4 _value64;

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

  _CGFloatx4Wrapper(double a, double b, double c, double d) {
    if (LP64) {
      _value64 = _CGFloat64x4(a, b, c, d);
    } else {
      _value32 = _CGFloat32x4(a, b, c, d);
    }
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  _CGFloatx4Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = _CGFloat64x4.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat32x4.fromPointer(ptr.cast());
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

class CGRect extends _CGFloatx4Wrapper {
  double get x => a;
  set x(double x) {
    a = x;
  }

  double get y => b;
  set y(double y) {
    b = y;
  }

  double get width => c;
  set width(double width) {
    c = width;
  }

  double get height => d;
  set height(double height) {
    d = height;
  }

  CGRect(double x, double y, double width, double height)
      : super(x, y, width, height);
  CGRect.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class UIEdgeInsets extends _CGFloatx4Wrapper {
  double get top => a;
  set top(double top) {
    a = top;
  }

  double get left => b;
  set left(double left) {
    b = left;
  }

  double get bottom => c;
  set bottom(double bottom) {
    c = bottom;
  }

  double get right => d;
  set right(double right) {
    d = right;
  }

  UIEdgeInsets(double top, double left, double bottom, double right)
      : super(top, left, bottom, right);
  UIEdgeInsets.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class NSDirectionalEdgeInsets extends _CGFloatx4Wrapper {
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

class _CGFloat32x6 extends Struct {
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

  factory _CGFloat32x6(
          double a, double b, double c, double d, double e, double f) =>
      allocate<_CGFloat32x6>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d
        ..e = e
        ..f = f;

  factory _CGFloat32x6.fromPointer(Pointer<_CGFloat32x6> ptr) {
    return ptr.ref;
  }
}

class _CGFloat64x6 extends Struct {
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

  factory _CGFloat64x6(
          double a, double b, double c, double d, double e, double f) =>
      allocate<_CGFloat64x6>().ref
        ..a = a
        ..b = b
        ..c = c
        ..d = d
        ..e = e
        ..f = f;

  factory _CGFloat64x6.fromPointer(Pointer<_CGFloat64x6> ptr) {
    return ptr.ref;
  }
}

class _CGFloatx6Wrapper extends NativeStruct {
  _CGFloat32x6 _value32;
  _CGFloat64x6 _value64;

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

  _CGFloatx6Wrapper(
      double a, double b, double c, double d, double e, double f) {
    if (LP64) {
      _value64 = _CGFloat64x6(a, b, c, d, e, f);
    } else {
      _value32 = _CGFloat32x6(a, b, c, d, e, f);
    }
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  _CGFloatx6Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = _CGFloat64x6.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat32x6.fromPointer(ptr.cast());
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

class CGAffineTransform extends _CGFloatx6Wrapper {
  double get tx => e;
  set tx(double tx) {
    e = tx;
  }

  double get ty => f;
  set ty(double ty) {
    f = ty;
  }

  CGAffineTransform(
      double a, double b, double c, double d, double tx, double ty)
      : super(a, b, c, d, tx, ty);
  CGAffineTransform.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
