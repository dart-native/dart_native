// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DartNativeGenerator
// **************************************************************************

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/foundation/collection/nsarray.dart';
import 'package:dart_native/src/ios/foundation/collection/nsdictionary.dart';
import 'package:dart_native/src/ios/foundation/collection/nsset.dart';
import 'package:dart_native/src/ios/foundation/nsvalue.dart';
import 'package:dart_native/src/ios/foundation/nsnumber.dart';
import 'package:dart_native/src/ios/foundation/notification.dart';
import 'package:dart_native/src/ios/foundation/nserror.dart';
import 'package:dart_native/src/ios/foundation/nsstring.dart';

bool _hadRanDartNative = false;
bool get hadRanDartNative => _hadRanDartNative;

void runDartNative() {
  if (_hadRanDartNative) {
    return;
  }
  _hadRanDartNative = true;

  registerTypeConvertor('NSArray', (ptr) {
    return NSArray.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableArray', (ptr) {
    return NSMutableArray.fromPointer(ptr);
  });

  registerTypeConvertor('NSDictionary', (ptr) {
    return NSDictionary.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableDictionary', (ptr) {
    return NSMutableDictionary.fromPointer(ptr);
  });

  registerTypeConvertor('NSSet', (ptr) {
    return NSSet.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableSet', (ptr) {
    return NSMutableSet.fromPointer(ptr);
  });

  registerTypeConvertor('NSValue', (ptr) {
    return NSValue.fromPointer(ptr);
  });

  registerTypeConvertor('NSNumber', (ptr) {
    return NSNumber.fromPointer(ptr);
  });

  registerTypeConvertor('NSNotification', (ptr) {
    return NSNotification.fromPointer(ptr);
  });

  registerTypeConvertor('NSError', (ptr) {
    return NSError.fromPointer(ptr);
  });

  registerTypeConvertor('NSString', (ptr) {
    return NSString.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableString', (ptr) {
    return NSMutableString.fromPointer(ptr);
  });
}
