import 'dart:ffi';

import 'package:flutter/material.dart';
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
    stub = NSObject(className: 'RuntimeStub').performSelector(Selector('foo13:'), [nil]);
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
                // List args = [
                //   -123,
                //   -12345,
                //   -123456,
                //   -123456,
                //   123,
                //   12345,
                //   123456,
                //   123456,
                //   123.456,
                //   123.456,
                //   '123456',
                //   Class('RuntimeStub'),
                //   Selector('foo12:'),
                //   NSObject(className: 'RuntimeStub'),
                //   NSObject(),
                // ];
                // for (var i = 0; i < 15; i++) {
                //   var result =
                //       stub.performSelector(Selector('foo$i:'), [args[i]]);
                //   print('foo$i result:$result');
                // }
                // var result = stub.performSelector(Selector('foo15'));
                // print('foo15 result:$result');
                
                Class cls = stub.performSelector(Selector('class'));
                print(cls);
              }),
        ),
      ),
    );
  }
}
