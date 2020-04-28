import 'dart:convert';

import 'package:dart_native/src/ios/foundation/internal/native_type_box.dart';

mixin _ToAlias {}

class BOOL = NativeBox<bool> with _ToAlias;

class char extends NativeNumBox<int> {
  const char(int raw) : super(raw);

  @override
  String toString() {
    return utf8.decode([raw]);
  }
}

class unsigned_char = char with _ToAlias;
class short = NativeNumBox<int> with _ToAlias;
class unsigned_short = NativeNumBox<int> with _ToAlias;
class unsigned_int = NativeNumBox<int> with _ToAlias;
class long = NativeNumBox<int> with _ToAlias;
class unsigned_long = NativeNumBox<int> with _ToAlias;
class long_long = NativeNumBox<int> with _ToAlias;
class unsigned_long_long = NativeNumBox<int> with _ToAlias;
class size_t = NativeNumBox<int> with _ToAlias;
class NSInteger = NativeNumBox<int> with _ToAlias;
class NSUInteger = NativeNumBox<int> with _ToAlias;
class float = NativeNumBox<double> with _ToAlias;
class CGFloat = NativeNumBox<double> with _ToAlias;
class CString = NativeBox<String> with _ToAlias;

class NSEnum extends NativeNumBox<int> {
  const NSEnum(int raw) : super(raw);
}

class NSOptions extends NativeNumBox<int> {
  const NSOptions(int raw) : super(raw);
}
