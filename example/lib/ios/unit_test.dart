import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/ios/delegatestub.dart';
import 'package:dart_native_example/ios/runtimestub.dart';

testIOS(RuntimeStub stub, DelegateStub delegate) {
  bool resultBool = stub.fooBool(false);
  print('fooBool result:$resultBool');

  NSString resultNSString = stub.fooNSString('This is NSString');
  print('fooNSString result:$resultNSString');

  String resultChar = stub.fooChar('A');
  print('fooChar result:$resultChar');

  String resultUChar = stub.fooUChar('A');
  print('fooUChar result:$resultUChar');

  String resultCharPtr = stub.fooCharPtr('test CString');
  print('fooCharPtr result:$resultCharPtr');

  NSObject resultObj = stub.fooObject(delegate);
  print('fooObject result:$resultObj');

  stub.fooDelegate(delegate);
  stub.fooStructDelegate(delegate);

  Block block = stub.fooBlock(_blockFunc);
  resultObj = block.invoke([stub]);
  print('fooBlock result:$resultObj');

  Block blockStret = stub.fooStretBlock(_blockStructFunc);
  CGAffineTransform resultStret = blockStret.invoke([CGAffineTransform(6, 5, 4, 3, 2, 1)]);
  print('fooStretBlock result:$resultStret');

  Block blockCString = stub.fooCStringBlock(_blockCStringFunc);
  String resultCString = blockCString.invoke(['test cstring arg']);
  print('fooCStringBlock result:$resultCString');

  CGSize size = stub.fooCGSize(CGSize(2, 1));
  print(size);

  CGPoint point = stub.fooCGPoint(CGPoint(2, 1));
  print(point);

  CGVector vector = stub.fooCGVector(CGVector(2, 1));
  print(vector);

  CGRect rect = stub.fooCGRect(CGRect(4, 3, 2, 1));
  print(rect);

  NSRange range = stub.fooNSRange(NSRange(2, 1));
  print(range);

  UIEdgeInsets insets = stub.fooUIEdgeInsets(UIEdgeInsets(4, 3, 2, 1));
  print(insets);

  NSDirectionalEdgeInsets dInsets =
      stub.fooNSDirectionalEdgeInsets(NSDirectionalEdgeInsets(4, 3, 2, 1));
  print(dInsets);

  CGAffineTransform transform =
      stub.fooCGAffineTransform(CGAffineTransform(6, 5, 4, 3, 2, 1));
  print(transform);

  NSArray array = stub.fooNSArray([1, 2.345, 'I\'m String', rect]);
  print(array);

  NSObject currentThread = Class('NSThread')
      .perform(Selector('currentThread'), onQueue: DispatchQueue.global());
  NSObject description = currentThread.perform(Selector('description'));
  String threadResult = NSString.fromPointer(description.pointer).value;
  print('currentThread: $threadResult');

  NSNotificationCenter.defaultCenter.addObserver(
      delegate, delegate.handleNotification, 'SampleDartNotification', nil);
}

Function _blockFunc = (NSObject a) {
  print('hello block! ${a.toString()}');
  return a;
};

Function _blockStructFunc = (CGRect a) {
  print('hello block stret! ${a.toString()}');
  return CGAffineTransform(12, 0, 12, 0, 12, 0);
};

Function _blockCStringFunc = (CString a) {
  print('hello block cstring! $a');
  return CString('test return cstring');
};
