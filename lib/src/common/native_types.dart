import 'dart:convert';
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
class char extends Box<int> with _ToAlias {
  char(int value) : super(value);

  @override
  String toString() {
    return utf8.decode([value]);
  }
}
class short = Box<int> with _ToAlias;
class unsigned_short = Box<int> with _ToAlias;
class unsigned_int = Box<int> with _ToAlias;
class long = Box<int> with _ToAlias;
class unsigned_long = Box<int> with _ToAlias;
class long_long = Box<int> with _ToAlias;
class unsigned_long_long = Box<int> with _ToAlias;
class size_t = Box<int> with _ToAlias;
class NSInteger = Box<int> with _ToAlias;
class NSUInteger = Box<int> with _ToAlias;
class float = Box<double> with _ToAlias;
class CGFloat = Box<double> with _ToAlias;

class _NSUInteger2_32 extends Struct<_NSUInteger2_32> {
  @Uint32()
  int a;
  @Uint32()
  int b;

  factory _NSUInteger2_32.allocate(int a, int b) =>
      Pointer<_NSUInteger2_32>.allocate().load<_NSUInteger2_32>()
        ..a = a
        ..b = b;

  factory _NSUInteger2_32.fromPointer(Pointer<_NSUInteger2_32> ptr) {
    return ptr.load<_NSUInteger2_32>();
  }
}

class _NSUInteger2_64 extends Struct<_NSUInteger2_64> {
  @Uint64()
  int a;
  @Uint64()
  int b;

  factory _NSUInteger2_64.allocate(int a, int b) =>
      Pointer<_NSUInteger2_64>.allocate().load<_NSUInteger2_64>()
        ..a = a
        ..b = b;

  factory _NSUInteger2_64.fromPointer(Pointer<_NSUInteger2_64> ptr) {
    return ptr.load<_NSUInteger2_64>();
  }
}
class _NSUInteger2_Wrapper {
  _NSUInteger2_32 _value32;
  _NSUInteger2_64 _value64;

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

  _NSUInteger2_Wrapper.allocate(int a, int b) {
    if (_is64bit) {
      _value64 = _NSUInteger2_64.allocate(a, b);
    } else {
      _value32 = _NSUInteger2_32.allocate(a, b);
    }
  }

  Pointer get addressOf => _is64bit ? _value64.addressOf : _value32.addressOf;

  free() => addressOf.free();

  _NSUInteger2_Wrapper.fromPointer(Pointer<Void> ptr) {
    if (_is64bit) {
      _value64 = _NSUInteger2_64.fromPointer(ptr.cast());
    } else {
      _value32 = _NSUInteger2_32.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    if (other == null) return false;
    return a == other.a && b == other.b;
  }

  @override
  int get hashCode => a.hashCode^b.hashCode;

  @override
  String toString() {
    return '$runtimeType=($a, $b)';
  }
}

class NSRange extends _NSUInteger2_Wrapper {
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

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  free() => addressOf.free();

  _CGFloat2_Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = _CGFloat2_64.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat2_32.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    if (other == null) return false;
    return a == other.a && b == other.b;
  }

  @override
  int get hashCode => a.hashCode^b.hashCode;

  @override
  String toString() {
    return '$runtimeType=($a, $b)';
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

  Pointer get addressOf => LP64 ? _value64.addressOf : _value32.addressOf;

  free() => addressOf.free();

  _CGFloat4_Wrapper.fromPointer(Pointer<Void> ptr) {
    if (LP64) {
      _value64 = _CGFloat4_64.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat4_32.fromPointer(ptr.cast());
    }
  }

  bool operator ==(other) {
    if (other == null) return false;
    return a == other.a && b == other.b && c == other.c && d == other.d;
  }

  @override
  int get hashCode => a.hashCode^b.hashCode^c.hashCode^d.hashCode;
  @override
  String toString() {
    return '$runtimeType=($a, $b, $c, $d)';
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

  CGRect.allocate(double x, double y, double width, double height)
      : super.allocate(x, y, width, height);
  CGRect.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

dynamic loadValueForNativeType(String type, dynamic value) {
  switch (type) {
    case 'BOOL':
      return BOOL(value);
    case 'NSInteger':
      return NSInteger(value);
    case 'NSUInteger':
      return NSUInteger(value);
    case 'CGFloat':
      return CGFloat(value);
    case 'char':
      return char(value);
    case 'short':
      return short(value);
    case 'unsigned short':
      return unsigned_short(value);
    case 'unsigned int':
      return unsigned_int(value);
    case 'long':
      return long(value);
    case 'unsigned long':
      return unsigned_long(value);
    case 'long long':
      return long_long(value);
    case 'unsigned long long':
      return unsigned_long_long(value);
    case 'size_t':
      return size_t(value);
    case 'float':
      return float(value);
    default:
      return value;
  }
}
