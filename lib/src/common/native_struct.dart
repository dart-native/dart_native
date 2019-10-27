import 'dart:ffi';

import 'package:dart_objc/src/common/precompile_macro.dart';

class _NSUInteger32x2 extends Struct<_NSUInteger32x2> {
  @Uint32()
  int a;
  @Uint32()
  int b;

  factory _NSUInteger32x2.allocate(int a, int b) =>
      Pointer<_NSUInteger32x2>.allocate().load<_NSUInteger32x2>()
        ..a = a
        ..b = b;

  factory _NSUInteger32x2.fromPointer(Pointer<_NSUInteger32x2> ptr) {
    return ptr.load<_NSUInteger32x2>();
  }
}

class _NSUInteger64x2 extends Struct<_NSUInteger64x2> {
  @Uint64()
  int a;
  @Uint64()
  int b;

  factory _NSUInteger64x2.allocate(int a, int b) =>
      Pointer<_NSUInteger64x2>.allocate().load<_NSUInteger64x2>()
        ..a = a
        ..b = b;

  factory _NSUInteger64x2.fromPointer(Pointer<_NSUInteger64x2> ptr) {
    return ptr.load<_NSUInteger64x2>();
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

  _NSUIntegerx2Wrapper.allocate(int a, int b) {
    if (_is64bit) {
      _value64 = _NSUInteger64x2.allocate(a, b);
    } else {
      _value32 = _NSUInteger32x2.allocate(a, b);
    }
  }

  Pointer get addressOf => _is64bit ? _value64.addressOf : _value32.addressOf;

  free() => addressOf.free();

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

  NSRange.allocate(int width, int length) : super.allocate(width, length);
  NSRange.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class _CGFloat32x2 extends Struct<_CGFloat32x2> {
  @Float()
  double a;
  @Float()
  double b;

  factory _CGFloat32x2.allocate(double a, double b) =>
      Pointer<_CGFloat32x2>.allocate().load<_CGFloat32x2>()
        ..a = a
        ..b = b;

  factory _CGFloat32x2.fromPointer(Pointer<_CGFloat32x2> ptr) {
    return ptr.load<_CGFloat32x2>();
  }
}

class _CGFloat64x2 extends Struct<_CGFloat64x2> {
  @Double()
  double a;
  @Double()
  double b;

  factory _CGFloat64x2.allocate(double a, double b) =>
      Pointer<_CGFloat64x2>.allocate().load<_CGFloat64x2>()
        ..a = a
        ..b = b;

  factory _CGFloat64x2.fromPointer(Pointer<_CGFloat64x2> ptr) {
    return ptr.load<_CGFloat64x2>();
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

  _CGFloatx2Wrapper.allocate(double a, double b) {
    if (LP64) {
      _value64 = _CGFloat64x2.allocate(a, b);
    } else {
      _value32 = _CGFloat32x2.allocate(a, b);
    }
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  free() => addressOf.free();

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

  CGSize.allocate(double width, double height) : super.allocate(width, height);
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

  CGPoint.allocate(double x, double y) : super.allocate(x, y);
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

  CGVector.allocate(double dx, double dy) : super.allocate(dx, dy);
  CGVector.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class _CGFloat32x4 extends Struct<_CGFloat32x4> {
  @Float()
  double a;
  @Float()
  double b;
  @Float()
  double c;
  @Float()
  double d;

  factory _CGFloat32x4.allocate(double a, double b, double c, double d) =>
      Pointer<_CGFloat32x4>.allocate().load<_CGFloat32x4>()
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory _CGFloat32x4.fromPointer(Pointer<_CGFloat32x4> ptr) {
    return ptr.load<_CGFloat32x4>();
  }
}

class _CGFloat64x4 extends Struct<_CGFloat64x4> {
  @Double()
  double a;
  @Double()
  double b;
  @Double()
  double c;
  @Double()
  double d;

  factory _CGFloat64x4.allocate(double a, double b, double c, double d) =>
      Pointer<_CGFloat64x4>.allocate().load<_CGFloat64x4>()
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory _CGFloat64x4.fromPointer(Pointer<_CGFloat64x4> ptr) {
    return ptr.load<_CGFloat64x4>();
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

  _CGFloatx4Wrapper.allocate(double a, double b, double c, double d) {
    if (LP64) {
      _value64 = _CGFloat64x4.allocate(a, b, c, d);
    } else {
      _value32 = _CGFloat32x4.allocate(a, b, c, d);
    }
  }

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  free() => addressOf.free();

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

  CGRect.allocate(double x, double y, double width, double height)
      : super.allocate(x, y, width, height);
  CGRect.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
