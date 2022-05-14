import 'dart:async';

import 'package:ffi/ffi.dart';
import 'package:dart_native_example/main.dn.dart';
import 'package:flutter/material.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/dart_native.dart';

import 'log.dart';
import 'dn_unit_test.dart';

@nativeRoot
void main() {
  Log.setLevel(LogLevel.verbose);
  runDartNativeExample();
  runApp(const DartNativeApp());
}

final interface = Interface("MyFirstInterface");

class DartNativeApp extends StatefulWidget {
  const DartNativeApp({Key? key}) : super(key: key);

  @override
  State createState() => _DartNativeAppState();
}

class _DartNativeAppState extends State<DartNativeApp> {
  final TextEditingController _controllerA = TextEditingController();
  final TextEditingController _controllerB = TextEditingController();
  String result = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // example: native call dart
    interface.setMethodCallHandler('totalCost',
        (double unitCost, int count, List list) async {
      return {'totalCost: ${unitCost * count}': list};
    });
    result = helloWorld();

    final data = getUTF8Data(result);
    // The number of bytes equals the length of uint8 list.
    final utf8Result =
        data.bytes.cast<Utf8>().toDartString(length: data.lengthInBytes);
    // They should be equal.
    assert(utf8Result == result);

    final unitTest = DNUnitTest();

    /// Run all test cases.
    await unitTest.runAllUnitTests();
    // test finalizer
    unitTest.addFinalizer(() {
      print('The instance of \'unitTest\' has been destroyed!');
    });
  }

  String helloWorld() {
    return interface.invokeMethodSync('hello', args: ['world']);
  }

  Future<T> sum<T>(T a, T b) {
    return interface.invokeMethod('sum', args: [a, b]);
  }

  NativeByte getUTF8Data(String str) {
    return interface.invokeMethodSync('getUTF8Data', args: [str]);
  }

  Future<void> calculate() async {
    final aStr = _controllerA.text;
    final bStr = _controllerB.text;
    String r;
    if (aStr.isNotEmpty && bStr.isNotEmpty) {
      int aPlusB = await sum(int.parse(aStr), int.parse(bStr));
      r = aPlusB.toString();
    } else {
      r = helloWorld();
    }
    setState(() {
      result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DartNative example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              textAlign: TextAlign.center,
              controller: _controllerA,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Input integer A',
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _controllerB,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Input integer B',
              ),
            ),
            Text(
              result,
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                calculate();
              },
              child: const Text('SUM'),
            ),
          ],
        ),
      ),
    );
  }
}
