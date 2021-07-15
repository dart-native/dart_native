import 'package:dart_native/src/common/native_basic_type.dart';
import 'package:flutter/material.dart';

class NativeBox<T> {
  final T raw;
  const NativeBox(this.raw);

  bool operator ==(other) {
    if (other is T) {
      return raw == other;
    }
    if (other is NativeBox) return raw == other.raw;
    return false;
  }

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() {
    return raw.toString();
  }
}

class NativeNumBox<T extends num> extends NativeBox<T> {
  const NativeNumBox(T raw) : super(raw);

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

class NativeIntBox extends NativeNumBox<int> {
  const NativeIntBox(int raw) : super(raw);

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

dynamic boxingBasicValue(String type, dynamic value) {
  switch (type) {
    case 'char':
      return char(value);
    case 'unsigned_char':
      return unsigned_char(value);
    case 'short':
      return short(value);
    case 'unsigned_short':
      return unsigned_short(value);
    case 'unsigned_int':
      return unsigned_int(value);
    case 'long':
      return long(value);
    case 'unsigned_long':
      return unsigned_long(value);
    case 'long_long':
      return long_long(value);
    case 'unsigned_long_long':
      return unsigned_long_long(value);
    case 'size_t':
      return size_t(value);
    case 'float':
      return float(value);
    default:
      return value;
  }
}
