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
    obj = stubNew.performSelector(Selector('foo13:'), [nil]);
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
                stubNew.release();
                print(stubNew.performSelector(Selector('class')));
                print(obj.performSelector(Selector('class')));
              }),
        ),
      ),
    );
  }
}
