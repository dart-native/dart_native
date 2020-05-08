import 'package:dart_native/src/ios/foundation/basic_type.dart';
import 'package:dart_native/src/ios/foundation/collection/nsarray.dart';
import 'package:dart_native/src/ios/foundation/collection/nsdictionary.dart';
import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';
import 'package:dart_native/src/ios/foundation/nsnumber.dart';
import 'package:dart_native/src/ios/foundation/collection/nsset.dart';
import 'package:dart_native/src/ios/foundation/nsstring.dart';
import 'package:dart_native/src/ios/foundation/nsvalue.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/nsobject_protocol.dart';

class NativeBox<T> {
  final T raw;
  const NativeBox(this.raw);

  bool operator ==(other) {
    if (other == null) return false;
    if (other is T) return raw == other;
    return raw == other.raw;
  }

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() {
    return raw.toString();
  }
}

class NativeNumBox<T extends num> extends NativeBox<T> {
  const NativeNumBox(num raw) : super(raw);

  /// Addition operator.
  T operator +(other) {
    if (other == null) {
      return raw;
    }
    if (other is T) {
      return raw + other;
    }
    return raw + other.raw;
  }

  /// Subtraction operator.
  T operator -(other) {
    if (other == null) {
      return raw;
    }
    if (other is T) {
      return raw - other;
    }
    return raw - other.raw;
  }

  /// Multiplication operator.
  T operator *(other) {
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
  const NativeIntBox(num raw) : super(raw);

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

  int operator <<(int shiftAmount) {
    if (shiftAmount == null) {
      return raw;
    }
    return raw << shiftAmount;
  }

  int operator >>(int shiftAmount) {
    if (shiftAmount == null) {
      return raw;
    }
    return raw >> shiftAmount;
  }
}

dynamic boxingBasicValue(String type, dynamic value) {
  switch (type) {
    case 'BOOL':
      return BOOL(value != 0);
    case 'NSInteger':
      return NSInteger(value);
    case 'NSUInteger':
      return NSUInteger(value);
    case 'CGFloat':
      return CGFloat(value);
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
    case 'CString':
      return CString(value);
    default:
      return value;
  }
}

id boxingElementForNativeCollection(dynamic e) {
  if (e is num || e is NativeBox || e is bool) {
    return NSNumber(e);
  } else if (e is NativeStruct) {
    return NSValue.valueWithStruct(e);
  } else if (e is String) {
    return NSString(e);
  } else if (e is id) {
    return e;
  } else if (e is List) {
    return NSArray(e);
  } else if (e is Map) {
    return NSDictionary(e);
  } else if (e is Set) {
    return NSSet(e);
  } else {
    throw 'Cannot boxing element $e';
  }
}

dynamic unboxingElementForDartCollection(id e) {
  if (e is id) {
    if (e.isKind(of: type(of: NSValue))) {
      return NSValue.fromPointer(e.pointer).raw;
    } else if (e.isKind(of: type(of: NSString))) {
      return NSString.fromPointer(e.pointer).raw;
    } else if (e.isKind(of: type(of: NSArray))) {
      return NSArray.fromPointer(e.pointer).raw;
    } else if (e.isKind(of: type(of: NSDictionary))) {
      return NSDictionary.fromPointer(e.pointer).raw;
    } else if (e.isKind(of: type(of: NSSet))) {
      return NSSet.fromPointer(e.pointer).raw;
    } else {
      return e;
    }
  } else {
    throw 'Cannot unboxing element $e';
  }
}
