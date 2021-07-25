import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/ios/delegatestub.dart';
import 'package:dart_native_example/ios/runtimestub.dart';

testIOS(RuntimeStub stub, DelegateStub delegate) {
  bool resultBool = stub.fooBOOL(false);
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

  CATransform3D transform3D = stub.fooCATransform3D(
      CATransform3D(16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1));
  print('fooCATransform3D result:$transform3D');

  List list = stub.fooNSArray([1, 2.345, 'I\'m String', rect]);
  print('NSArray to List: $list');

  list = stub.fooNSMutableArray([1, 2.345, 'I\'m String', rect]);
  print('NSMutableArray to List: $list');

  Map map = stub.fooNSDictionary({'foo': 'bar'});
  print('NSDictionary to Map: $map');

  map = stub.fooNSMutableDictionary({'foo': 'bar'});
  print('NSMutableDictionary to Map: $map');

  Set set = stub.fooNSSet(Set.from([1, 2.345, 'I\'m String', rect]));
  print('NSSet to Set: $set');

  set = stub.fooNSMutableSet(Set.from([1, 2.345, 'I\'m String', rect]));
  print('fooNSMutableSet to Set: $set');

  stub.fooBlock((NSObject a) {
    print('hello block! ${a.description}');
    return a;
  });

  stub.fooStretBlock((CGAffineTransform a) {
    print('hello block stret! ${a.toString()}');
    return CGAffineTransform(12, 0, 12, 0, 12, 0);
  });

  stub.fooCStringBlock((CString a) {
    print('hello block cstring! $a');
    return CString('test return cstring');
  });

  stub.fooCompletion(() {
    print('hello completion block!');
  });

  stub.fooDelegate(delegate);

  stub.fooStructDelegate(delegate);

  String resultNSString = stub.fooNSString('This is NSString');
  print('fooNSString result:$resultNSString');

  resultNSString = stub.fooNSMutableString('This is NSString');
  print('fooNSMutableString result:$resultNSString');

  NSObjectRef<NSError> ref = NSObjectRef<NSError>();
  stub.fooWithError(ref);
  print('fooWithError result:${ref.value.description}');

  TestOptions options =
      stub.fooWithOptions(TestOptions(TestOptionsOne | TestOptionsTwo));
  print('fooWithOptions result:$options');

  Class('NSThread')
      .performAsync(SEL('currentThread'), onQueue: DispatchQueue.global())
      .then((currentThread) {
    print('currentThread: ${currentThread.description}');
  });

  NSNotificationCenter.defaultCenter.addObserver(
      delegate, delegate.handleNotification, 'SampleDartNotification', nil);

  Isolate.spawn(_checkTimer, 'isolate0');
  Isolate.spawn(_checkTimer, 'isolate1');
}

void _checkTimer(String isolateID) async {
  RuntimeStub stub = RuntimeStub();
  DelegateStub delegate = DelegateStub();
  Timer.periodic(new Duration(seconds: 1), (Timer t) {
    stub.fooCompletion(() {
      print('hello completion block on $isolateID!');
    });
    stub.fooDelegate(delegate);
  });
}
