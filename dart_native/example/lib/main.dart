import 'package:dart_native_example/main.dn.dart';
import 'package:flutter/material.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

import 'dn_unit_test.dart';

@nativeRoot
void main() {
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
  String _text = 'Using DartNative';
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    
    /// run all test case
    try {
      final unitTest = DNUnitTest();
      await unitTest.runAllUnitTests();
    } catch (e) {
      _text = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(_text),
        ),
      ),
    );
  }
}
