import 'dart:ffi';

import 'package:dart_objc/src/common/precompile_macro.dart';
import 'package:ffi/ffi.dart';

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

class _NSUIntegerx2Wrapper {
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

class _CGFloatx2Wrapper {
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

class _CGFloatx4Wrapper {
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
