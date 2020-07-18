import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
// import 'package:uikit/uikit.dart';

class TestOptions extends NSOptions {
  const TestOptions(dynamic raw) : super(raw);
  TestOptions.fromPointer(Pointer<Void> ptr) : super(ptr.address);
}

const TestOptions TestOptionsNone = TestOptions(0);

const TestOptions TestOptionsOne = TestOptions(1 << 0);

const TestOptions TestOptionsTwo = TestOptions(1 << 1);

abstract class SampleDelegate {
  registerSampleDelegate() {
    registerProtocolCallback(this, callback, 'callback', SampleDelegate);
    registerProtocolCallback(
        this, callbackStruct, 'callbackStruct:', SampleDelegate);
  }

  NSObject callback();
  CGRect callbackStruct(CGRect rect);
}

typedef NSObject BarBlock(NSObject a);

typedef CGAffineTransform StretBlock(CGAffineTransform a);

typedef CString CStringRetBlock(CString a);

typedef CGFloat CGFloatRetBlock(CGFloat a);

@native
class RuntimeStub extends NSObject {
  RuntimeStub([Class isa]) : super(Class('RuntimeStub'));
  RuntimeStub.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  bool fooBOOL(bool b) {
    return perform(SEL('fooBOOL:'), args: [b]);
  }

  int fooInt8(int int8) {
    return perform(SEL('fooInt8:'), args: [int8]);
  }

  int fooInt16(int int16) {
    return perform(SEL('fooInt16:'), args: [int16]);
  }

  int fooInt32(int int32) {
    return perform(SEL('fooInt32:'), args: [int32]);
  }

  int fooInt64(int int64) {
    return perform(SEL('fooInt64:'), args: [int64]);
  }

  int fooUInt8(int uint8) {
    return perform(SEL('fooUInt8:'), args: [uint8]);
  }

  int fooUInt16(int uint16) {
    return perform(SEL('fooUInt16:'), args: [uint16]);
  }

  int fooUInt32(int uint32) {
    return perform(SEL('fooUInt32:'), args: [uint32]);
  }

  int fooUInt64(int uint64) {
    return perform(SEL('fooUInt64:'), args: [uint64]);
  }

  double fooFloat(double f) {
    return perform(SEL('fooFloat:'), args: [f]);
  }

  double fooDouble(double d) {
    return perform(SEL('fooDouble:'), args: [d]);
  }

  String fooCharPtr(String charPtr) {
    return perform(SEL('fooCharPtr:'), args: [charPtr]);
  }

  Class fooClass(Class cls) {
    Pointer<Void> result =
        perform(SEL('fooClass:'), args: [cls], decodeRetVal: false);
    return Class.fromPointer(result);
  }

  SEL fooSEL(SEL sel) {
    Pointer<Void> result =
        perform(SEL('fooSEL:'), args: [sel], decodeRetVal: false);
    return SEL.fromPointer(result);
  }

  NSObject fooObject(NSObject object) {
    Pointer<Void> result =
        perform(SEL('fooObject:'), args: [object], decodeRetVal: false);
    return NSObject.fromPointer(result);
  }

  Pointer<Void> fooPointer(Pointer<Void> p) {
    return perform(SEL('fooPointer:'), args: [p]);
  }

  void fooVoid() {
    perform(SEL('fooVoid'));
  }

  CGSize fooCGSize(CGSize size) {
    Pointer<Void> result =
        perform(SEL('fooCGSize:'), args: [size], decodeRetVal: false);
    return CGSize.fromPointer(result);
  }

  CGPoint fooCGPoint(CGPoint point) {
    Pointer<Void> result =
        perform(SEL('fooCGPoint:'), args: [point], decodeRetVal: false);
    return CGPoint.fromPointer(result);
  }

  CGVector fooCGVector(CGVector vector) {
    Pointer<Void> result =
        perform(SEL('fooCGVector:'), args: [vector], decodeRetVal: false);
    return CGVector.fromPointer(result);
  }

  CGRect fooCGRect(CGRect rect) {
    Pointer<Void> result =
        perform(SEL('fooCGRect:'), args: [rect], decodeRetVal: false);
    return CGRect.fromPointer(result);
  }

  NSRange fooNSRange(NSRange range) {
    Pointer<Void> result =
        perform(SEL('fooNSRange:'), args: [range], decodeRetVal: false);
    return NSRange.fromPointer(result);
  }

  UIOffset fooUIOffset(UIOffset offset) {
    Pointer<Void> result =
        perform(SEL('fooUIOffset:'), args: [offset], decodeRetVal: false);
    return UIOffset.fromPointer(result);
  }

  UIEdgeInsets fooUIEdgeInsets(UIEdgeInsets insets) {
    Pointer<Void> result =
        perform(SEL('fooUIEdgeInsets:'), args: [insets], decodeRetVal: false);
    return UIEdgeInsets.fromPointer(result);
  }

  @NativeAvailable(ios: '11.0')
  NSDirectionalEdgeInsets fooNSDirectionalEdgeInsets(
      NSDirectionalEdgeInsets insets) {
    Pointer<Void> result = perform(SEL('fooNSDirectionalEdgeInsets:'),
        args: [insets], decodeRetVal: false);
    return NSDirectionalEdgeInsets.fromPointer(result);
  }

  CGAffineTransform fooCGAffineTransform(CGAffineTransform transform) {
    Pointer<Void> result = perform(SEL('fooCGAffineTransform:'),
        args: [transform], decodeRetVal: false);
    return CGAffineTransform.fromPointer(result);
  }

  List fooNSArray(List array) {
    Pointer<Void> result =
        perform(SEL('fooNSArray:'), args: [array], decodeRetVal: false);
    return NSArray.fromPointer(result).raw;
  }

  List fooNSMutableArray(List array) {
    NSMutableArray _array = NSMutableArray(array);
    Pointer<Void> result =
        perform(SEL('fooNSMutableArray:'), args: [_array], decodeRetVal: false);
    return NSMutableArray.fromPointer(result).raw;
  }

  Map fooNSDictionary(Map dict) {
    Pointer<Void> result =
        perform(SEL('fooNSDictionary:'), args: [dict], decodeRetVal: false);
    return NSDictionary.fromPointer(result).raw;
  }

  Map fooNSMutableDictionary(Map dict) {
    NSMutableDictionary _dict = NSMutableDictionary(dict);
    Pointer<Void> result = perform(SEL('fooNSMutableDictionary:'),
        args: [_dict], decodeRetVal: false);
    return NSMutableDictionary.fromPointer(result).raw;
  }

  Set fooNSSet(Set set) {
    Pointer<Void> result =
        perform(SEL('fooNSSet:'), args: [set], decodeRetVal: false);
    return NSSet.fromPointer(result).raw;
  }

  Set fooNSMutableSet(Set set) {
    NSMutableSet _set = NSMutableSet(set);
    Pointer<Void> result =
        perform(SEL('fooNSMutableSet:'), args: [_set], decodeRetVal: false);
    return NSMutableSet.fromPointer(result).raw;
  }

  void fooBlock(BarBlock block) {
    perform(SEL('fooBlock:'), args: [block]);
  }

  void fooStretBlock(StretBlock block) {
    perform(SEL('fooStretBlock:'), args: [block]);
  }

  void fooCStringBlock(CStringRetBlock block) {
    perform(SEL('fooCStringBlock:'), args: [block]);
  }

  void fooDelegate(SampleDelegate delegate) {
    perform(SEL('fooDelegate:'), args: [delegate]);
  }

  void fooStructDelegate(SampleDelegate delegate) {
    perform(SEL('fooStructDelegate:'), args: [delegate]);
  }

  String fooNSString(String str) {
    Pointer<Void> result =
        perform(SEL('fooNSString:'), args: [str], decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  String fooNSMutableString(String str) {
    NSMutableString _str = NSMutableString(str);
    Pointer<Void> result =
        perform(SEL('fooNSMutableString:'), args: [_str], decodeRetVal: false);
    return NSMutableString.fromPointer(result).raw;
  }

  void fooWithError(NSObjectRef<NSError> error) {
    perform(SEL('fooWithError:'), args: [error]);
  }

  TestOptions fooWithOptions(TestOptions options) {
    Pointer<Void> result =
        perform(SEL('fooWithOptions:'), args: [options], decodeRetVal: false);
    return TestOptions.fromPointer(result);
  }
}
