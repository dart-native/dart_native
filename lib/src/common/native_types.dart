import 'dart:ffi';

import 'dart:io';

mixin _ToAlias {}

class Box<T> {
  T value;
  Box(this.value);
}

bool __LP64__ = sizeOf<IntPtr>() == 8;

class BOOL = Box<bool> with _ToAlias;
class NSInteger = Box<int> with _ToAlias;
class NSUInteger = Box<int> with _ToAlias;
class CGFloat = Box<double> with _ToAlias;

class _CGFloat_2_32 extends Struct<_CGFloat_2_32> {
  @Float()
  double a;
  @Float()
  double b;

  factory _CGFloat_2_32.allocate(double a, double b) =>
      Pointer<_CGFloat_2_32>.allocate().load<_CGFloat_2_32>()
        ..a = a
        ..b = b;

  factory _CGFloat_2_32.fromPointer(Pointer<_CGFloat_2_32> ptr) {
    return ptr.load<_CGFloat_2_32>();
  }
}

class _CGFloat_2_64 extends Struct<_CGFloat_2_64> {
  @Double()
  double a;
  @Double()
  double b;

  factory _CGFloat_2_64.allocate(double a, double b) =>
      Pointer<_CGFloat_2_64>.allocate().load<_CGFloat_2_64>()
        ..a = a
        ..b = b;

  factory _CGFloat_2_64.fromPointer(Pointer<_CGFloat_2_64> ptr) {
    return ptr.load<_CGFloat_2_64>();
  }
}

class _CGFloat2_Wrapper {
  _CGFloat_2_32 _value32;
  _CGFloat_2_64 _value64;

  double get a => __LP64__ ? _value64.a : _value32.a;
  set a(double a) {
    if (__LP64__) {
      _value64.a = a;
    } else {
      _value32.a = a;
    }
  }

  double get b => __LP64__ ? _value64.b : _value32.b;
  set b(double b) {
    if (__LP64__) {
      _value64.b = b;
    } else {
      _value32.b = b;
    }
  }

  _CGFloat2_Wrapper.allocate(double a, double b) {
    if (__LP64__) {
      _value64 = _CGFloat_2_64.allocate(a, b);
    } else {
      _value32 = _CGFloat_2_32.allocate(a, b);
    }
  }

  free() => __LP64__ ? _value64.addressOf.free() : _value32.addressOf.free();

  _CGFloat2_Wrapper.fromPointer(Pointer<Void> ptr) {
    if (__LP64__) {
      _value64 = _CGFloat_2_64.fromPointer(ptr.cast());
    } else {
      _value32 = _CGFloat_2_32.fromPointer(ptr.cast());
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
    default:
      return value;
  }
}
