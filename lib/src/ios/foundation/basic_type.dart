import 'dart:convert';

import 'package:dart_native/src/ios/foundation/internal/native_type_box.dart';

mixin _ToAlias {}

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
