import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/ios/delegatestub.dart';
import 'package:dart_native_example/ios/runtimestub.dart';

testIOS(RuntimeStub stub, DelegateStub delegate) {
  bool resultBool = stub.fooBool(false);
  print('fooBool result:$resultBool');

  int resultInt8 = stub.fooInt8(-123);
  print('fooInt8 result:$resultInt8');

  int resultInt16 = stub.fooInt16(-12345);
  print('fooInt16 result:$resultInt16');

  int resultInt32 = stub.fooInt32(-1234567);
  print('fooInt32 result:$resultInt32');

  int resultInt64 = stub.fooInt64(-1234567);
  print('fooInt64 result:$resultInt64');

  int resultUInt8 = stub.fooUInt8(123);
  print('fooUInt8 result:$resultUInt8');

  int resultUInt16 = stub.fooUInt16(12345);
  print('fooUInt16 result:$resultUInt16');

  int resultUInt32 = stub.fooUInt32(1234567);
  print('fooUInt32 result:$resultUInt32');

  int resultUInt64 = stub.fooUInt64(1234567);
  print('fooUInt64 result:$resultUInt64');

  double resultFloat = stub.fooFloat(1.2345);
  print('fooFloat result:$resultFloat');

  double resultDouble = stub.fooDouble(1.2345);
  print('fooDouble result:$resultDouble');

  String resultCharPtr = stub.fooCharPtr('test CString');
  print('fooCharPtr result:$resultCharPtr');

  Class resultClass = stub.fooClass(stub.isa);
  print('fooClass result:$resultClass');

  SEL resultSEL = stub.fooSEL(SEL('fooSEL'));
  print('fooSEL result:$resultSEL');

  NSObject resultObj = stub.fooObject(delegate);
  print('fooObject result:$resultObj');

  Pointer<Void> resultPtr = stub.fooPointer(stub.pointer);
  print('fooPointer result:$resultPtr');

  stub.fooVoid();

  CGSize size = stub.fooCGSize(CGSize(2, 1));
  print('fooCGSize result:$size');

  CGPoint point = stub.fooCGPoint(CGPoint(2, 1));
  print('fooCGPoint result:$point');

  CGVector vector = stub.fooCGVector(CGVector(2, 1));
  print('fooCGVector result:$vector');

  CGRect rect = stub.fooCGRect(CGRect(4, 3, 2, 1));
  print('fooCGRect result:$rect');

  NSRange range = stub.fooNSRange(NSRange(2, 1));
  print('fooNSRange result:$range');

  UIOffset offset = stub.fooUIOffset(UIOffset(2, 1));
  print('fooUIOffset result:$offset');

  UIEdgeInsets insets = stub.fooUIEdgeInsets(UIEdgeInsets(4, 3, 2, 1));
  print('fooUIEdgeInsets result:$insets');

  NSDirectionalEdgeInsets dInsets =
      stub.fooNSDirectionalEdgeInsets(NSDirectionalEdgeInsets(4, 3, 2, 1));
  print('fooNSDirectionalEdgeInsets result:$dInsets');

  CGAffineTransform transform =
      stub.fooCGAffineTransform(CGAffineTransform(6, 5, 4, 3, 2, 1));
  print('fooCGAffineTransform result:$transform');

  List list = stub.fooNSArray([1, 2.345, 'I\'m String', rect]);
  print('NSArray to List: $list');

  list = stub.fooNSMutableArray([1, 2.345, 'I\'m String', rect]);
  print('NSMutableArray to List: $list');

  Block block = stub.fooBlock((NSString a) {
    print('hello block! ${a.toString()}');
    return a;
  });
  resultObj = block.invoke([stub]);
  print('fooBlock result:$resultObj');

  Block blockStret = stub.fooStretBlock((CGRect a) {
    print('hello block stret! ${a.toString()}');
    return CGAffineTransform(12, 0, 12, 0, 12, 0);
  });
  CGAffineTransform resultStret =
      blockStret.invoke([CGAffineTransform(6, 5, 4, 3, 2, 1)]);
  print('fooStretBlock result:$resultStret');

  Block blockCString = stub.fooCStringBlock((CString a) {
    print('hello block cstring! $a');
    return CString('test return cstring');
  });
  String resultCString = blockCString.invoke(['test cstring arg']);
  print('fooCStringBlock result:$resultCString');

  stub.fooDelegate(delegate);
  stub.fooStructDelegate(delegate);

  NSString resultNSString = stub.fooNSString('This is NSString');
  print('fooNSString result:$resultNSString');

  NSObject currentThread = Class('NSThread')
      .perform(SEL('currentThread'), onQueue: DispatchQueue.global());
  NSObject description = currentThread.perform(SEL('description'));
  String threadResult = NSString.fromPointer(description.pointer).value;
  print('currentThread: $threadResult');

  NSNotificationCenter.defaultCenter.addObserver(
      delegate, delegate.handleNotification, 'SampleDartNotification', nil);
}
