import 'dart:convert';

import 'package:dart_native/src/common/native_type_box.dart';

mixin _ToAlias {}

/// Stands for `char` in C.
// ignore: camel_case_types
class char extends NativeIntBox {
  const char(int raw) : super(raw);

  @override
  String toString() {
    return utf8.decode([raw]);
  }
}

/// Stands for `unsigned char` in C.
class unsigned_char = char with _ToAlias;

/// Stands for `byte` in Java.
class byte = NativeIntBox with _ToAlias;

/// Stands for `short` in C.
class short = NativeIntBox with _ToAlias;

/// Stands for `unsigned short` in C.
class unsigned_short = NativeIntBox with _ToAlias;

/// Stands for `unsigned int` in C.
class unsigned_int = NativeIntBox with _ToAlias;

/// Stands for `long` in C.
class long = NativeIntBox with _ToAlias;

/// Stands for `unsigned long` in C.
class unsigned_long = NativeIntBox with _ToAlias;

/// Stands for `long long` in C.
class long_long = NativeIntBox with _ToAlias;

/// Stands for `unsigned long long` in C.
class unsigned_long_long = NativeIntBox with _ToAlias;

/// Stands for `size_t` in C.
class size_t = NativeIntBox with _ToAlias;

/// Stands for `int8_t` in C.
class int8_t = NativeIntBox with _ToAlias;

/// Stands for `int16_t` in C.
class int16_t = NativeIntBox with _ToAlias;

/// Stands for `int32_t` in C.
class int32_t = NativeIntBox with _ToAlias;

/// Stands for `int64_t` in C.
class int64_t = NativeIntBox with _ToAlias;

/// Stands for `uint8_t` in C.
class uint8_t = NativeIntBox with _ToAlias;

/// Stands for `uint16_t` in C.
class uint16_t = NativeIntBox with _ToAlias;

/// Stands for `uint32_t` in C.
class uint32_t = NativeIntBox with _ToAlias;

/// Stands for `uint64_t` in C.
class uint64_t = NativeIntBox with _ToAlias;

/// Stands for `float` in C.
class float = NativeNumBox<double> with _ToAlias;
