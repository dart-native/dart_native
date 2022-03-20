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

  registerTypeConvertor('NSRange', (ptr) {
    return NSRange.fromPointer(ptr);
  });

  registerTypeConvertor('CATransform3D', (ptr) {
    return CATransform3D.fromPointer(ptr);
  });

  registerTypeConvertor('CGAffineTransform', (ptr) {
    return CGAffineTransform.fromPointer(ptr);
  });

  registerTypeConvertor('CGSize', (ptr) {
    return CGSize.fromPointer(ptr);
  });

  registerTypeConvertor('NSSize', (ptr) {
    return NSSize.fromPointer(ptr);
  });

  registerTypeConvertor('NSNotification', (ptr) {
    return NSNotification.fromPointer(ptr);
  });

  registerTypeConvertor('NSValue', (ptr) {
    return NSValue.fromPointer(ptr);
  });

  registerTypeConvertor('NSArray', (ptr) {
    return NSArray.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableArray', (ptr) {
    return NSMutableArray.fromPointer(ptr);
  });

  registerTypeConvertor('NSDirectionalEdgeInsets', (ptr) {
    return NSDirectionalEdgeInsets.fromPointer(ptr);
  });

  registerTypeConvertor('NSSet', (ptr) {
    return NSSet.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableSet', (ptr) {
    return NSMutableSet.fromPointer(ptr);
  });

  registerTypeConvertor('UIOffset', (ptr) {
    return UIOffset.fromPointer(ptr);
  });

  registerTypeConvertor('NSNumber', (ptr) {
    return NSNumber.fromPointer(ptr);
  });

  registerTypeConvertor('CGVector', (ptr) {
    return CGVector.fromPointer(ptr);
  });

  registerTypeConvertor('NSError', (ptr) {
    return NSError.fromPointer(ptr);
  });

  registerTypeConvertor('CGRect', (ptr) {
    return CGRect.fromPointer(ptr);
  });

  registerTypeConvertor('NSRect', (ptr) {
    return NSRect.fromPointer(ptr);
  });

  registerTypeConvertor('NSDictionary', (ptr) {
    return NSDictionary.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableDictionary', (ptr) {
    return NSMutableDictionary.fromPointer(ptr);
  });

  registerTypeConvertor('CGPoint', (ptr) {
    return CGPoint.fromPointer(ptr);
  });

  registerTypeConvertor('NSPoint', (ptr) {
    return NSPoint.fromPointer(ptr);
  });

  registerTypeConvertor('UIEdgeInsets', (ptr) {
    return UIEdgeInsets.fromPointer(ptr);
  });

  registerTypeConvertor('NSEdgeInsets', (ptr) {
    return NSEdgeInsets.fromPointer(ptr);
  });

  registerTypeConvertor('NSString', (ptr) {
    return NSString.fromPointer(ptr);
  });

  registerTypeConvertor('NSMutableString', (ptr) {
    return NSMutableString.fromPointer(ptr);
  });

  registerTypeConvertor('NSData', (ptr) {
    return NSData.fromPointer(ptr);
  });
}
