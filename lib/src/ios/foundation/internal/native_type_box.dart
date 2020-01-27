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
  T value;
  NativeBox(this.value);

  bool operator ==(other) {
    if (other == null) return false;
    if (other is T) return value == other;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
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
    case 'unsigned char':
      return unsigned_char(value);
    case 'short':
      return short(value);
    case 'unsigned short':
      return unsigned_short(value);
    case 'unsigned int':
      return unsigned_int(value);
    case 'long':
      return long(value);
    case 'unsigned long':
      return unsigned_long(value);
    case 'long long':
      return long_long(value);
    case 'unsigned long long':
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
      return NSValue.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSString))) {
      return NSString.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSArray))) {
      return NSArray.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSDictionary))) {
      return NSDictionary.fromPointer(e.pointer).value;
    } else if (e.isKind(of: type(of: NSSet))) {
      return NSSet.fromPointer(e.pointer).value;
    } else {
      return e;
    }
  } else {
    throw 'Cannot unboxing element $e';
  }
}
