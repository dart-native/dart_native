import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:dart_objc/dart_objc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NSObject stub;
  @override
  void initState() {
    super.initState();
    stub = NSObject(isa: Class('RuntimeStub'));
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
                NSObject object = NSObject();
                var result = stub.performSelector('foo:', [object]);
                print(result);
              }),
        ),
      ),
    );
  }
}
