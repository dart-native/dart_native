import 'dart:ffi';

import 'package:dart_objc/src/common/precompile_macro.dart';

mixin _ToAlias {}

class Box<T> {
  T value;
  Box(this.value);

  bool operator ==(other) {
    if (other == null) return false;
    if (other is T) return value == other;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
  }
}

class BOOL = Box<bool> with _ToAlias;
class NSInteger = Box<int> with _ToAlias;
class NSUInteger = Box<int> with _ToAlias;
class CGFloat = Box<double> with _ToAlias;

class _CGFloat2_32 extends Struct<_CGFloat2_32> {
  @Float()
  double a;
  @Float()
  double b;

  factory _CGFloat2_32.allocate(double a, double b) =>
      Pointer<_CGFloat2_32>.allocate().load<_CGFloat2_32>()
        ..a = a
        ..b = b;

  factory _CGFloat2_32.fromPointer(Pointer<_CGFloat2_32> ptr) {
    return ptr.load<_CGFloat2_32>();
  }
}

class _CGFloat2_64 extends Struct<_CGFloat2_64> {
  @Double()
  double a;
  @Double()
  double b;

  factory _CGFloat2_64.allocate(double a, double b) =>
      Pointer<_CGFloat2_64>.allocate().load<_CGFloat2_64>()
        ..a = a
        ..b = b;

  factory _CGFloat2_64.fromPointer(Pointer<_CGFloat2_64> ptr) {
    return ptr.load<_CGFloat2_64>();
  }
}

class _CGFloat2_Wrapper {
  _CGFloat2_32 _value32;
  _CGFloat2_64 _value64;

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

  _CGFloat2_Wrapper.allocate(double a, double b) {
    if (LP64) {
      _value64 = _CGFloat2_64.allocate(a, b);
    } else {
      _value32 = _CGFloat2_32.allocate(a, b);
    }
  }

  free() => LP64 ? _value64.addressOf.free() : _value32.addressOf.free();

  _CGFloat2_Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = _CGFloat2_64.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat2_32.fromPointer(ptr.cast());
    }
  }

  @override
  String toString() {
    return '{$a, $b}';
  }
}

class CGSize extends _CGFloat2_Wrapper {
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

class CGPoint extends _CGFloat2_Wrapper {
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

class CGVector extends _CGFloat2_Wrapper {
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

class _CGFloat4_32 extends Struct<_CGFloat4_32> {
  @Float()
  double a;
  @Float()
  double b;
  @Float()
  double c;
  @Float()
  double d;

  factory _CGFloat4_32.allocate(double a, double b, double c, double d) =>
      Pointer<_CGFloat4_32>.allocate().load<_CGFloat4_32>()
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory _CGFloat4_32.fromPointer(Pointer<_CGFloat4_32> ptr) {
    return ptr.load<_CGFloat4_32>();
  }
}

class _CGFloat4_64 extends Struct<_CGFloat4_64> {
  @Double()
  double a;
  @Double()
  double b;
  @Double()
  double c;
  @Double()
  double d;

  factory _CGFloat4_64.allocate(double a, double b, double c, double d) =>
      Pointer<_CGFloat4_64>.allocate().load<_CGFloat4_64>()
        ..a = a
        ..b = b
        ..c = c
        ..d = d;

  factory _CGFloat4_64.fromPointer(Pointer<_CGFloat4_64> ptr) {
    return ptr.load<_CGFloat4_64>();
  }
}

class _CGFloat4_Wrapper {
  _CGFloat4_32 _value32;
  _CGFloat4_64 _value64;

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

  _CGFloat4_Wrapper.allocate(double a, double b, double c, double d) {
    if (LP64) {
      _value64 = _CGFloat4_64.allocate(a, b, c, d);
    } else {
      _value32 = _CGFloat4_32.allocate(a, b, c, d);
    }
  }

  free() => LP64 ? _value64.addressOf.free() : _value32.addressOf.free();

  _CGFloat4_Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = _CGFloat4_64.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat4_32.fromPointer(ptr.cast());
    }
  }

  @override
  String toString() {
    return '{$a, $b, $c, $d}';
  }
}

class CGRect extends _CGFloat4_Wrapper {
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

  CGRect.allocate(double x, double y, double width, double height) : super.allocate(x, y, width, height);
  CGRect.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

dynamic loadValueForNativeType(String type, dynamic value) {
  switch (type) {
    case 'BOOL':// TODO: BOOL is signed char on 32bit; bool on 64bit.
      return BOOL(value);
    case 'NSInteger':
      return NSInteger(value);
    case 'NSUInteger':
      return NSUInteger(value);
    case 'CGFloat':
      return CGFloat(value);
    default:
      return value;
  }
}
