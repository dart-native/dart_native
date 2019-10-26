import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:dart_objc/dart_objc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NSObject stubNew;
  NSObject obj;
  Block block;

  @override
  void initState() {
    super.initState();
    // final start = DateTime.now().millisecondsSinceEpoch;
    // String version;
    // for (var i = 0; i < 100000; i++) {
    // NSObject device = Class('UIDevice').performSelector(Selector('currentDevice'));
    // NSObject nsstring = device.performSelector(Selector('systemVersion'));
    // version = nsstring.performSelector(Selector('UTF8String'));
    // }
    // final cost = DateTime.now().millisecondsSinceEpoch - start;
    // print(cost);
    stubNew = NSObject(className: 'RuntimeStub');
    Function testFunc = (NSObject a) {
      print('hello block! ${a.toString()}');
      return 1;
    };
    block = stubNew.perform(Selector('fooBlock:'), args: [testFunc]);
    int result = block.invoke([stubNew]);
    print(result);
  }

  Future<void> press() async {
    final stubNewPtr = stubNew.pointer;
    stubNew.release();
    final objPtr = obj.pointer;
    // obj.release();
    // NSObject.fromPointer(stubNewPtr);
    NSObject oo = NSObject.fromPointer(objPtr);
    Class cls = oo.perform(Selector('class'));
    print(cls);
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
                press();
              }),
        ),
      ),
    );
  }
}
