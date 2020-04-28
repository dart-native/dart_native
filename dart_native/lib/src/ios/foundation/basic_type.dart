import 'dart:convert';

import 'package:dart_native/src/ios/foundation/internal/native_type_box.dart';

mixin _ToAlias {}

class BOOL = NativeBox<bool> with _ToAlias;

class char extends NativeIntBox {
  const char(int raw) : super(raw);

  @override
  String toString() {
    return utf8.decode([raw]);
  }
}

class unsigned_char = char with _ToAlias;
class short = NativeIntBox with _ToAlias;
class unsigned_short = NativeIntBox with _ToAlias;
class unsigned_int = NativeIntBox with _ToAlias;
class long = NativeIntBox with _ToAlias;
class unsigned_long = NativeIntBox with _ToAlias;
class long_long = NativeIntBox with _ToAlias;
class unsigned_long_long = NativeIntBox with _ToAlias;
class size_t = NativeIntBox with _ToAlias;
class NSInteger = NativeIntBox with _ToAlias;
class NSUInteger = NativeIntBox with _ToAlias;
class float = NativeNumBox<double> with _ToAlias;
class CGFloat = NativeNumBox<double> with _ToAlias;
class CString = NativeBox<String> with _ToAlias;

class NSEnum extends NativeIntBox {
  const NSEnum(int raw) : super(raw);
}

class NSOptions extends NativeIntBox {
  const NSOptions(int raw) : super(raw);
}
