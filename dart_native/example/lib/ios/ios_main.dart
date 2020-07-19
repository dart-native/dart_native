import 'package:dart_native_example/ios/delegatestub.dart';
import 'package:dart_native_example/ios/runtimeson.dart';
import 'package:dart_native_example/ios/unit_test.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class IOSApp extends StatefulWidget {
  @override
  _IOSAppState createState() => _IOSAppState();
}

class _IOSAppState extends State<IOSApp> {
  RuntimeSon stub = RuntimeSon().retain();
  DelegateStub delegate = DelegateStub().retain();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    testIOS(stub, delegate);
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

  @override
  void dispose() {
    stub.release();
    delegate.release();
    super.dispose();
  }
}
