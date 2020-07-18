import 'package:dart_native/src/common/native_type_box.dart';

mixin _ToAlias {}

class BOOL = NativeBox<bool> with _ToAlias;
class NSInteger = NativeIntBox with _ToAlias;
class NSUInteger = NativeIntBox with _ToAlias;
class CGFloat = NativeNumBox<double> with _ToAlias;
class CString = NativeBox<String> with _ToAlias;

class NSEnum extends NativeIntBox {
  const NSEnum(int raw) : super(raw);
}

class NSOptions extends NativeIntBox {
  const NSOptions(int raw) : super(raw);
}
