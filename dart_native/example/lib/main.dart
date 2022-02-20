import 'package:dart_native_example/main.dn.dart';
import 'package:flutter/material.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/dart_native.dart';

import 'log.dart';
import 'dn_unit_test.dart';

@nativeRoot
void main() {
  Log.setLevel(LogLevel.verbose);
  DartNative.init();
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
    interface.setMethodCallHandler('totalCost', (double unitCost, int count, List list) {
      return {'totalCost: ${unitCost * count}': list};
    });
    result = helloWorld();
    final unitTest = DNUnitTest();
    /// run all test case
    await unitTest.runAllUnitTests();
  }

  String helloWorld() {
    return interface.invoke('hello', args: ['world']);
  }

  Future<int> sum(int a, int b) {
    return interface.invokeAsync('sum', args: [a, b]);
  }

  void testCallback() {
    interface.invoke('testCallback', args: [
      (bool success, String result) {
        if (success) {
          Log.i(result);
        }
      }
    ]);
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
    testCallback();
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
