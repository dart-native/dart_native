import 'package:dart_objc_example/delegatestub.dart';
import 'package:dart_objc_example/runtimestub.dart';
import 'package:flutter/material.dart';
import 'package:dart_objc/dart_objc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RuntimeStub stub = RuntimeStub().retain();
  DelegateStub delegate = DelegateStub().retain();

  @override
  void initState() {
    super.initState();

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

    Block block = stub.fooBlock(testFunc);
    NSObject result = block.invoke([stub]);
    print(result);

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

    // stub.release();

    NSObject currentThread = Class('NSThread')
        .perform(Selector('currentThread'), onQueue: DispatchQueue.global());
    NSObject description = currentThread.perform(Selector('description'));
    String threadResult = NSString.fromPointer(description.pointer).value;
    print('currentThread: $threadResult');

    // DispatchQueue.main.async(() {
    //   NSObject currentThread = Class('NSThread').perform(Selector('currentThread'));
    //   NSObject description = currentThread.perform(Selector('description'));
    //   String result = NSString.fromPointer(description.pointer).value;
    //   print('currentThread: $result');
    // });
    // String sysver;
    // int start = DateTime.now().millisecondsSinceEpoch;
    // // UIDevice.currentDevice.systemVersion
    // for (var i = 0; i < 10000; i++) {
    //   NSObject device = Class('UIDevice').perform(Selector('currentDevice'));
    //   NSObject version = device.perform(Selector('systemVersion'));
    //   sysver = NSString.fromPointer(version.pointer).value;
    // }
    // int duration = DateTime.now().millisecondsSinceEpoch - start;
    // print('msg_duration1:$msg_duration1, msg_duration2:$msg_duration2, msg_duration3:$msg_duration3, msg_duration4:$msg_duration4, msg_duration5:$msg_duration5');
    // print('duration:$duration');
  }

  Function testFunc = (NSObject a) {
    print('hello block! ${a.toString()}');
    return a;
  };

  Future<void> press() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: MaterialButton(
              child: Text('dialog'),
              onPressed: () {
                press();
              }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    stub.release();
    delegate.release();
    super.dispose();
  }
}
