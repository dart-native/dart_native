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
    stub = NSObject(className: 'RuntimeStub');
    String str = Class('RuntimeStub').toString();
    print(str);
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
                for (var i = 10; i < 16; i++) {
                  var result = stub.performSelector(Selector('foo$i:'), [object]);
                  print('foo$i result:$result');
                }
              }),
        ),
      ),
    );
  }
}
