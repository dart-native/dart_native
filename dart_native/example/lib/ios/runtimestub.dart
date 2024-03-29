// Generated by @dartnative/codegen:
// https://www.npmjs.com/package/@dartnative/codegen

import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
// You can uncomment this line when this package is ready.
// import 'package:foundation/foundation.dart';
// You can uncomment this line when this package is ready.
// import 'package:appkit/appkit.dart';
// You can uncomment this line when this package is ready.
// import 'package:uikit/uikit.dart';

typedef ItemIndex = NSOptions;

const ItemIndex itemIndexNone = 0;

const ItemIndex itemIndexOne = 1 << 0;

const ItemIndex itemIndexTwo = 1 << 1;

abstract class SampleDelegate {
  registerSampleDelegate() {
    registerProtocolCallback(this, callback, 'callback', SampleDelegate);
    registerProtocolCallback(
        this, callbackStruct, 'callbackStruct:', SampleDelegate);
  }

  String? callback();
  CGRect? callbackStruct(CGRect rect);
}

typedef BarBlock = NSObject? Function(NSObject? a);

typedef StretBlock = CGAffineTransform? Function(CGAffineTransform? a);

typedef CStringRetBlock = CString? Function(CString? a);

typedef StringRetBlock = String? Function(String? a);

typedef NSDictionaryRetBlock = NSDictionary? Function(NSDictionary? a);

typedef CGFloatRetBlock = CGFloat? Function(CGFloat? a);

@native()
class RuntimeStub extends NSObject {
  RuntimeStub([Class? isa]) : super(isa ?? Class('RuntimeStub'));
  RuntimeStub.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  bool? fooBOOL(bool b) {
    return performSync(SEL('fooBOOL:'), args: [b]);
  }

  int? fooInt8(int int8) {
    return performSync(SEL('fooInt8:'), args: [int8]);
  }

  int? fooInt16(int int16) {
    return performSync(SEL('fooInt16:'), args: [int16]);
  }

  int? fooInt32(int int32) {
    return performSync(SEL('fooInt32:'), args: [int32]);
  }

  int? fooInt64(int int64) {
    return performSync(SEL('fooInt64:'), args: [int64]);
  }

  int? fooUInt8(int uint8) {
    return performSync(SEL('fooUInt8:'), args: [uint8]);
  }

  int? fooUInt16(int uint16) {
    return performSync(SEL('fooUInt16:'), args: [uint16]);
  }

  int? fooUInt32(int uint32) {
    return performSync(SEL('fooUInt32:'), args: [uint32]);
  }

  int? fooUInt64(int uint64) {
    return performSync(SEL('fooUInt64:'), args: [uint64]);
  }

  double? fooFloat(double f) {
    return performSync(SEL('fooFloat:'), args: [f]);
  }

  double? fooDouble(double d) {
    return performSync(SEL('fooDouble:'), args: [d]);
  }

  String? fooCharPtr(String charPtr) {
    return performSync(SEL('fooCharPtr:'), args: [charPtr]);
  }

  Class? fooClass(Class cls) {
    Pointer<Void> result =
        performSync(SEL('fooClass:'), args: [cls], decodeRetVal: false);
    return Class.fromPointer(result);
  }

  SEL? fooSEL(SEL sel) {
    Pointer<Void> result =
        performSync(SEL('fooSEL:'), args: [sel], decodeRetVal: false);
    return SEL.fromPointer(result);
  }

  NSObject? fooObject(NSObject object) {
    Pointer<Void> result =
        performSync(SEL('fooObject:'), args: [object], decodeRetVal: false);
    return NSObject.fromPointer(result);
  }

  Pointer<Void>? fooPointer(Pointer<Void> p) {
    return performSync(SEL('fooPointer:'), args: [p]);
  }

  void fooVoid() {
    performSync(SEL('fooVoid'));
  }

  CGSize? fooCGSize(CGSize size) {
    Pointer<Void> result =
        performSync(SEL('fooCGSize:'), args: [size], decodeRetVal: false);
    return CGSize.fromPointer(result);
  }

  CGPoint? fooCGPoint(CGPoint point) {
    Pointer<Void> result =
        performSync(SEL('fooCGPoint:'), args: [point], decodeRetVal: false);
    return CGPoint.fromPointer(result);
  }

  CGVector? fooCGVector(CGVector vector) {
    Pointer<Void> result =
        performSync(SEL('fooCGVector:'), args: [vector], decodeRetVal: false);
    return CGVector.fromPointer(result);
  }

  CGRect? fooCGRect(CGRect rect) {
    Pointer<Void> result =
        performSync(SEL('fooCGRect:'), args: [rect], decodeRetVal: false);
    return CGRect.fromPointer(result);
  }

  NSRange? fooNSRange(NSRange range) {
    Pointer<Void> result =
        performSync(SEL('fooNSRange:'), args: [range], decodeRetVal: false);
    return NSRange.fromPointer(result);
  }

  UIOffset? fooUIOffset(UIOffset offset) {
    Pointer<Void> result =
        performSync(SEL('fooUIOffset:'), args: [offset], decodeRetVal: false);
    return UIOffset.fromPointer(result);
  }

  UIEdgeInsets? fooUIEdgeInsets(UIEdgeInsets insets) {
    Pointer<Void> result = performSync(SEL('fooUIEdgeInsets:'),
        args: [insets], decodeRetVal: false);
    return UIEdgeInsets.fromPointer(result);
  }

  @NativeAvailable(ios: '11.0', macos: '10.15')
  NSDirectionalEdgeInsets? fooNSDirectionalEdgeInsets(
      NSDirectionalEdgeInsets insets) {
    Pointer<Void> result = performSync(SEL('fooNSDirectionalEdgeInsets:'),
        args: [insets], decodeRetVal: false);
    return NSDirectionalEdgeInsets.fromPointer(result);
  }

  CGAffineTransform? fooCGAffineTransform(CGAffineTransform transform) {
    Pointer<Void> result = performSync(SEL('fooCGAffineTransform:'),
        args: [transform], decodeRetVal: false);
    return CGAffineTransform.fromPointer(result);
  }

  CATransform3D? fooCATransform3D(CATransform3D transform3D) {
    Pointer<Void> result = performSync(SEL('fooCATransform3D:'),
        args: [transform3D], decodeRetVal: false);
    return CATransform3D.fromPointer(result);
  }

  List? fooNSArray(List array) {
    Pointer<Void> result =
        performSync(SEL('fooNSArray:'), args: [array], decodeRetVal: false);
    return NSArray.fromPointer(result).raw;
  }

  List? fooNSMutableArray(List array) {
    NSMutableArray _array = NSMutableArray(array);
    Pointer<Void> result = performSync(SEL('fooNSMutableArray:'),
        args: [_array], decodeRetVal: false);
    return NSMutableArray.fromPointer(result).raw;
  }

  Map? fooNSDictionary(Map dict) {
    Pointer<Void> result =
        performSync(SEL('fooNSDictionary:'), args: [dict], decodeRetVal: false);
    return NSDictionary.fromPointer(result).raw;
  }

  Map? fooNSMutableDictionary(Map dict) {
    NSMutableDictionary _dict = NSMutableDictionary(dict);
    Pointer<Void> result = performSync(SEL('fooNSMutableDictionary:'),
        args: [_dict], decodeRetVal: false);
    return NSMutableDictionary.fromPointer(result).raw;
  }

  Set? fooNSSet(Set set) {
    Pointer<Void> result =
        performSync(SEL('fooNSSet:'), args: [set], decodeRetVal: false);
    return NSSet.fromPointer(result).raw;
  }

  Set? fooNSMutableSet(Set set) {
    NSMutableSet _set = NSMutableSet(set);
    Pointer<Void> result =
        performSync(SEL('fooNSMutableSet:'), args: [_set], decodeRetVal: false);
    return NSMutableSet.fromPointer(result).raw;
  }

  void fooBlock(BarBlock block) {
    performSync(SEL('fooBlock:'), args: [block]);
  }

  void fooStretBlock(StretBlock block) {
    performSync(SEL('fooStretBlock:'), args: [block]);
  }

  void fooCompletion(void Function() block) {
    performSync(SEL('fooCompletion:'), args: [block]);
  }

  void fooCStringBlock(CStringRetBlock block) {
    performSync(SEL('fooCStringBlock:'), args: [block]);
  }

  void fooStringBlock(StringRetBlock block) {
    performSync(SEL('fooStringBlock:'), args: [block]);
  }

  void fooNSDictionaryBlock(NSDictionaryRetBlock block) {
    performSync(SEL('fooNSDictionaryBlock:'), args: [block]);
  }

  void fooDelegate(SampleDelegate delegate) {
    performSync(SEL('fooDelegate:'), args: [delegate]);
  }

  void fooStructDelegate(SampleDelegate delegate) {
    performSync(SEL('fooStructDelegate:'), args: [delegate]);
  }

  String? fooNSString(String str) {
    return performSync(SEL('fooNSString:'), args: [str]);
  }

  String? fooNSMutableString(String str) {
    NSMutableString _str = NSMutableString(str);
    Pointer<Void> result = performSync(SEL('fooNSMutableString:'),
        args: [_str], decodeRetVal: false);
    return NSMutableString.fromPointer(result).raw;
  }

  bool? fooWithError(NSObjectRef<NSError> error) {
    return performSync(SEL('fooWithError:'), args: [error]);
  }

  ItemIndex? fooWithOptions(ItemIndex options) {
    Pointer<Void> result = performSync(SEL('fooWithOptions:'),
        args: [options], decodeRetVal: false);
    return result.address;
  }
}
