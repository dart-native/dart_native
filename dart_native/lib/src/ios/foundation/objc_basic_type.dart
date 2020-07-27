import 'package:dart_native/src/common/native_type_box.dart';

mixin _ToAlias {}

/// These native types ONLY for Objective-C Block description.
class BOOL = NativeBox<bool> with _ToAlias;
class NSInteger = NativeIntBox with _ToAlias;
class NSUInteger = NativeIntBox with _ToAlias;
class CGFloat = NativeNumBox<double> with _ToAlias;
class CString = NativeBox<String> with _ToAlias;

/// Wrapper for Objective-C NS_ENUM
class NSEnum extends NativeIntBox {
  const NSEnum(int raw) : super(raw);
}

/// Wrapper for Objective-C NS_OPTIONS
class NSOptions extends NativeIntBox {
  const NSOptions(int raw) : super(raw);
}
