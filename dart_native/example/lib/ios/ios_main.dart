import 'package:dart_native_example/ios/delegatestub.dart';
import 'package:dart_native_example/ios/runtimeson.dart';
import 'package:dart_native_example/ios/unit_test.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class IOSApp extends StatefulWidget {
  @override
  _IOSAppState createState() => _IOSAppState();
}

class _IOSAppState extends State<IOSApp> {
  static const platform = const MethodChannel('sample.dartnative.com');
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    RuntimeSon stub = RuntimeSon();
    DelegateStub delegate = DelegateStub();
    testIOS(stub, delegate);
    // Benchmark
    String testString =
        'This is a long string: sdlfdksjflksndhiofuu2893873(*（%￥#@）*&……￥撒肥料开发时傅雷家书那份会计师东方丽景三等奖';
    int time = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < 10000; i++) {
      String _ = await platform.invokeMethod('fooNSString:', testString);
    }

    print(
        "Flutter Channel Cost: ${DateTime.now().millisecondsSinceEpoch - time}");
    time = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < 10000; i++) {
      String _ = stub.fooNSString(testString);
    }

    print("DartNative Cost: ${DateTime.now().millisecondsSinceEpoch - time}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Using DartNative\n'),
        ),
      ),
    );
  }
}
