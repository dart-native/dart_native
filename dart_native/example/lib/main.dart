import 'package:dart_native_example/main.dn.dart';
import 'package:flutter/material.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/dart_native.dart';
import 'package:flutter/services.dart';

import 'dn_unit_test.dart';

@nativeRoot
void main() {
  DartNative.init();
  runDartNativeExample();
  runApp(DartNativeApp());
}

class DartNativeApp extends StatefulWidget {
  @override
  _DartNativeAppState createState() => _DartNativeAppState();
}

class _DartNativeAppState extends State<DartNativeApp> {
  static const platform = const MethodChannel('sample.dartnative.com');
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final unitTest = DNUnitTest();

    String testString = "";
    int time = 0;
    /// Benchmark
    testString =
        'This is a long string: sdlfdksjflksndhiofuu2893873(*（%￥#@）*&……￥撒肥料开发时傅雷家书那份会计师东方丽景三等奖';
    time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      platform.invokeMethod('setFooString', testString);
    }
    print(
        "Flutter Channel Cost: ${DateTime.now().millisecondsSinceEpoch - time}");

    time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      unitTest.setFooString(testString);
    }
    print("DartNative Cost: ${DateTime.now().millisecondsSinceEpoch - time}");

    time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      String _ = await platform.invokeMethod('fooString', testString);
    }
    print(
        "Flutter Channel Cost: ${DateTime.now().millisecondsSinceEpoch - time}");

    time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      String _ = unitTest.fooString(testString);
    }
    print("DartNative Cost: ${DateTime.now().millisecondsSinceEpoch - time}");

    /// run all test case
    unitTest.runAllUnitTests();
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
