import 'package:dart_native_example/main.dn.dart';
import 'package:flutter/material.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/dart_native.dart';

import 'dn_unit_test.dart';

@nativeRoot
void main() {
  DartNative.init();
  runDartNativeExample();
  runApp(const DartNativeApp());
}

class DartNativeApp extends StatefulWidget {
  const DartNativeApp({Key? key}) : super(key: key);

  @override
  State createState() => _DartNativeAppState();
}

class _DartNativeAppState extends State<DartNativeApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final unitTest = DNUnitTest();
    /// run all test case
    await unitTest.runAllUnitTests();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('Using DartNative\n'),
        ),
      ),
    );
  }
}
