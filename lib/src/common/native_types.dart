// TODO: native int,double types.

mixin _ToAlias{}

class Box<T> {
  T value;
  Box(this.value);
}

class BOOL = Box<bool> with _ToAlias;
class NSInteger = Box<int> with _ToAlias;
class NSUInteger = Box<int> with _ToAlias;
class CGFloat = Box<double> with _ToAlias;