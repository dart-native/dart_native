mixin _ToAlias {}

/// Stands for `float` in Java.
// ignore: camel_case_types
class float = _NativeNum<double> with _ToAlias;

/// Stands for `short` in Java.
// ignore: camel_case_types
class short = _NativeInt with _ToAlias;

/// Stands for `long` in Java.
// ignore: camel_case_types
class long = _NativeInt with _ToAlias;

/// Stands for `byte` in Java.
// ignore: camel_case_types
class byte = _NativeInt with _ToAlias;

/// Stands for `char` in Java.
// ignore: camel_case_types
class jchar = _NativeInt with _ToAlias;

class _NativeType<T> {
  final T raw;
  const _NativeType(this.raw);

  @override
  bool operator ==(other) {
    if (other is T) {
      return raw == other;
    }
    if (other is _NativeType) return raw == other.raw;
    return false;
  }

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() {
    return raw.toString();
  }
}

class _NativeNum<T extends num> extends _NativeType<T> {
  const _NativeNum(T raw) : super(raw);

  /// Addition operator.
  num operator +(other) {
    if (other == null) {
      return raw;
    }
    if (other is T) {
      return raw + other;
    }
    return raw + other.raw;
  }

  /// Subtraction operator.
  num operator -(other) {
    if (other == null) {
      return raw;
    }
    if (other is T) {
      return raw - other;
    }
    return raw - other.raw;
  }

  /// Multiplication operator.
  num operator *(other) {
    if (other == null) {
      return raw;
    }
    if (other is T) {
      return raw * other;
    }
    return raw * other.raw;
  }

  /// Division operator.
  double operator /(other) {
    if (other == null) {
      return raw.toDouble();
    }
    if (other is T) {
      return raw / other;
    }
    return raw / other.raw;
  }
}

class _NativeInt extends _NativeNum<int> {
  const _NativeInt(int raw) : super(raw);

  int operator &(dynamic other) {
    if (other == null) {
      return raw;
    }
    if (other is int) {
      return raw & other;
    }
    return raw & other.raw;
  }

  int operator |(dynamic other) {
    if (other == null) {
      return raw;
    }
    if (other is int) {
      return raw | other;
    }
    return raw | other.raw;
  }

  int operator ^(dynamic other) {
    if (other == null) {
      return raw;
    }
    if (other is int) {
      return raw ^ other;
    }
    return raw ^ other.raw;
  }

  int operator ~() {
    return ~raw;
  }

  int operator <<(int? shiftAmount) {
    if (shiftAmount == null) {
      return raw;
    }
    return raw << shiftAmount;
  }

  int operator >>(int? shiftAmount) {
    if (shiftAmount == null) {
      return raw;
    }
    return raw >> shiftAmount;
  }
}
