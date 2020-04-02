import 'package:dart_native_example/android/runtimestub.dart';
import 'package:dart_native_example/android/unit_test.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AndroidNewApp extends StatefulWidget {
  @override
  _AndroidNewApp createState() => _AndroidNewApp();
}

class _AndroidNewApp extends State<AndroidNewApp> {
  RuntimeStub stub = RuntimeStub();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    stub.setTargetClass("com/dartnative/dart_native_example/MainActivity");
    testAndroid(stub);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FlatButton(
          onPressed: (){
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
