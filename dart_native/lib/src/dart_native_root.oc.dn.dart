// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DartNativeOCGenerator
// **************************************************************************

import 'package:dart_native/dart_native.dart';

bool _hadRanDartNative = false;
bool get hadRanDartNative => _hadRanDartNative;

void runOCDartNative() {
  if (_hadRanDartNative) {
    return;
  }
  _hadRanDartNative = true;

  registerTypeConvertor('NSValue', (ptr) {
    return NSValue.fromPointer(ptr);
  });

  registerTypeConvertor('NSNumber', (ptr) {
    return NSNumber.fromPointer(ptr);
  });

  registerTypeConvertor('NSDictionary', (ptr) {
    return NSDictionary.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableDictionary', (ptr) {
    return NSMutableDictionary.fromPointer(ptr);
  });

  registerTypeConvertor('NSError', (ptr) {
    return NSError.fromPointer(ptr);
  });

  registerTypeConvertor('NSSet', (ptr) {
    return NSSet.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableSet', (ptr) {
    return NSMutableSet.fromPointer(ptr);
  });

  registerTypeConvertor('NSArray', (ptr) {
    return NSArray.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableArray', (ptr) {
    return NSMutableArray.fromPointer(ptr);
  });

  registerTypeConvertor('NSString', (ptr) {
    return NSString.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableString', (ptr) {
    return NSMutableString.fromPointer(ptr);
  });

  registerTypeConvertor('NSNotification', (ptr) {
    return NSNotification.fromPointer(ptr);
  });
}
