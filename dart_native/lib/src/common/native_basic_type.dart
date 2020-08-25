import 'dart:convert';

import 'package:dart_native/src/common/native_type_box.dart';

mixin _ToAlias {}

// ignore: camel_case_types
class char extends NativeIntBox {
  const char(int raw) : super(raw);

  @override
  String toString() {
    return utf8.decode([raw]);
  }
}

class unsigned_char = char with _ToAlias;
class byte = NativeIntBox with _ToAlias;
class short = NativeIntBox with _ToAlias;
class unsigned_short = NativeIntBox with _ToAlias;
class unsigned_int = NativeIntBox with _ToAlias;
class long = NativeIntBox with _ToAlias;
class unsigned_long = NativeIntBox with _ToAlias;
class long_long = NativeIntBox with _ToAlias;
class unsigned_long_long = NativeIntBox with _ToAlias;
class size_t = NativeIntBox with _ToAlias;
class int8_t = NativeIntBox with _ToAlias;
class int16_t = NativeIntBox with _ToAlias;
class int32_t = NativeIntBox with _ToAlias;
class int64_t = NativeIntBox with _ToAlias;
class uint8_t = NativeIntBox with _ToAlias;
class uint16_t = NativeIntBox with _ToAlias;
class uint32_t = NativeIntBox with _ToAlias;
class uint64_t = NativeIntBox with _ToAlias;
class float = NativeNumBox<double> with _ToAlias;
