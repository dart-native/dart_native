import 'dart:convert';

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

dynamic boxForValue(String type, dynamic value) {
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
