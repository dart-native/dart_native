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
  RuntimeStub stub = RuntimeStub();
  DelegateStub delegate = DelegateStub();

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
    int result = block.invoke([stub]);
    print(result);
    
    CGRect rect = stub.fooCGRect(CGRect.allocate(4, 3, 2, 1));
    print(rect);
    rect.free();
    stub.release();

    int start = DateTime.now().millisecondsSinceEpoch;
    // UIDevice.currentDevice.systemVersion
    // for (var i = 0; i < 1000000; i++) {
    //   NSObject device = Class('UIDevice').perform(Selector('currentDevice'));
    //   NSObject version = device.perform(Selector('systemVersion'));
    //   sysver = NSString.fromPointer(version.pointer).value;
    // }
    int duration = DateTime.now().millisecondsSinceEpoch - start;
    // print('duration:$duration, selectorDuration:${stub.selectorDuration}');
  }

  Function testFunc = (NSObject a) {
    print('hello block! ${a.toString()}');
    return 101;
  };

  Future<void> press() async {
    delegate.release();
  }

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
}
