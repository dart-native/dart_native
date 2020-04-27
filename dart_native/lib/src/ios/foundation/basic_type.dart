import 'dart:convert';

import 'package:dart_native/src/ios/foundation/internal/native_type_box.dart';

mixin _ToAlias {}

class BOOL = NativeBox<bool> with _ToAlias;

class char extends NativeBox<int> {
  const char(int raw) : super(raw);

  @override
  String toString() {
    return utf8.decode([raw]);
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
class CString = NativeBox<String> with _ToAlias;

class NSEnum extends NativeBox<int> {
  const NSEnum(int raw) : super(raw);
}

const NSEnum a_NSEnum = NSEnum(0);

class NSOptions<T> extends NativeBox<int> {
  const NSOptions(int raw) : super(raw);
  NSOptions operator |(NSOptions other) {
    return NSOptions(this.raw|other.raw);
  }
}

class TestOptions extends NSOptions {
  const TestOptions(int raw) : super(raw);
}

const TestOptions a_NSOptions = TestOptions(1);
const TestOptions b_NSOptions = TestOptions(2);
