import 'package:dart_native/src/darwin/runtime/id.dart';
import 'package:dart_native/src/darwin/foundation/internal/native_struct.dart';
import 'package:dart_native/src/darwin/foundation/nsnumber.dart';
import 'package:dart_native/src/darwin/foundation/collection/nsarray.dart';
import 'package:dart_native/src/darwin/foundation/collection/nsdictionary.dart';
import 'package:dart_native/src/darwin/foundation/collection/nsset.dart';
import 'package:dart_native/src/darwin/foundation/nsstring.dart';
import 'package:dart_native/src/darwin/foundation/nsvalue.dart';
import 'package:dart_native/src/darwin/runtime/nsobject_protocol.dart';

id boxingObjCType(dynamic e) {
  if (e is num || e is bool) {
    return NSNumber(e);
  } else if (e is NativeStruct) {
    return NSValue.valueWithStruct(e);
  } else if (e is String) {
    return NSString(e);
  } else if (e is List) {
    return NSArray(e);
  } else if (e is Map) {
    return NSDictionary(e);
  } else if (e is Set) {
    return NSSet(e);
  } else if (e is id) {
    return e;
  } else {
    throw 'Cannot boxing element $e';
  }
}

dynamic unboxingObjCType(dynamic e) {
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
    }
  }
  return e;
}
