import 'package:dart_native_example/android/runtimestub.dart';
import 'package:dart_native_example/android/unit_test.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class AndroidNewApp extends StatefulWidget {
  @override
  _AndroidNewApp createState() => _AndroidNewApp();
}

class _AndroidNewApp extends State<AndroidNewApp> {
  static const platform = const MethodChannel('dart_native.example');

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Benchmark
    String testString =
        'This is a long string: sdlfdksjflksndhiofuu2893873(*（%￥#@）*&……￥撒肥料开发时傅雷家书那份会计师东方丽景三等奖';
    int time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      String _ = await platform.invokeMethod('channelString', testString);
    }
    print(
        "Flutter Channel String Cost: ${DateTime.now().millisecondsSinceEpoch - time}");
    time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      // String _ = stub.getString(testString);
    }
    print("DartNative String Cost: ${DateTime.now().millisecondsSinceEpoch - time}");

    time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      int _ = await platform.invokeMethod('channelInt', testString);
    }
    print(
        "Flutter Channel int Cost: ${DateTime.now().millisecondsSinceEpoch - time}");
    time = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10000; i++) {
      // int _ = stub.getInt(100);
    }
    print("DartNative int Cost: ${DateTime.now().millisecondsSinceEpoch - time}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FlatButton(
          onPressed: () {
            RuntimeStub stub = RuntimeStub();
            testAndroid(stub);
          },
          child: Text('Using DartNative\n'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
