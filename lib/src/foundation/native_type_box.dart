import 'dart:convert';

mixin _ToAlias {}

class NativeBox<T> {
  T value;
  NativeBox(this.value);

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

class BOOL = NativeBox<bool> with _ToAlias;

class char extends NativeBox<int> with _ToAlias {
  char(int value) : super(value);

  @override
  String toString() {
    return utf8.decode([value]);
  }
}

class unsigned_char = char with _ToAlias;
class short = NativeBox<int> with _ToAlias;
class unsigned_short = NativeBox<int> with _ToAlias;
class unsigned_int = NativeBox<int> with _ToAlias;
class long = NativeBox<int> with _ToAlias;
class unsigned_long = NativeBox<int> with _ToAlias;
class long_long = NativeBox<int> with _ToAlias;
class unsigned_long_long = NativeBox<int> with _ToAlias;
class size_t = NativeBox<int> with _ToAlias;
class NSInteger = NativeBox<int> with _ToAlias;
class NSUInteger = NativeBox<int> with _ToAlias;
class float = NativeBox<double> with _ToAlias;
class CGFloat = NativeBox<double> with _ToAlias;

dynamic boxForValue(String type, dynamic value) {
  switch (type) {
    case 'BOOL':
      return BOOL(value != 0);
    case 'NSInteger':
      return NSInteger(value);
    case 'NSUInteger':
      return NSUInteger(value);
    case 'CGFloat':
      return CGFloat(value);
    case 'char':
      return char(value);
    case 'unsigned char':
      return unsigned_char(value);
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
