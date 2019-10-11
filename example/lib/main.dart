import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:dart_objc/dart_objc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    invoke();
  }

  // test
  void invoke() {
    final Pointer<Utf8> strPtr = Utf8.toUtf8('test_str:%@');
    final Pointer<Pointer<Utf8>> strPtrPtr = Pointer<Pointer<Utf8>>.allocate();
    strPtrPtr.store(strPtr);
    // Pointer<Void> str = invokeMethod(
    //     getClass('NSString'), 'stringWithUTF8String:',
    //     args: strPtrPtr.cast());
    // final Pointer<Pointer<Void>> args = Pointer<Pointer<Void>>.allocate(count: 2);
    // args.elementAt(0).store(str);
    NSObject object = NSObject();
    // args.elementAt(1).store(object);
    // Pointer<Void> result = invokeMethod(getClass('NSString'), 'stringWithFormat:', args: args);
    NSObject stub = NSObject(isa: Class('RuntimeStub'));
    // final Pointer<Int8> arg = Pointer<Int8>.allocate();
    // arg.store(123);
    // final Pointer<Pointer<Int8>> result = Pointer<Pointer<Int8>>.allocate();
    // result.store(arg);
    stub.invokeMethod(stub, 'foo:',
        args: Pointer<Pointer<Void>>.allocate()..store(object.instance));
    // Pointer<Pointer<Void>> argsPtrPtr = Pointer<Pointer<Void>>.allocate()..store(str);
    // invokeMethod(stub, 'foo:', args: argsPtrPtr);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
