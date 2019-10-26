import 'package:dart_objc_example/runtimestub.dart';
import 'package:flutter/material.dart';
import 'package:dart_objc/dart_objc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RuntimeStub stub = RuntimeStub();
  NSObject obj;
  Block block;

  @override
  void initState() {
    super.initState();

    block = stub.fooBlock(testFunc);
    int result = block.invoke([stub]);
    print(result);

    CGRect rect = stub.fooCGRect(CGRect.allocate(4, 3, 2, 1));
    print(rect);
  }

  Function testFunc = (NSObject a) {
    print('hello block! ${a.toString()}');
    return 101;
  };

  Future<void> press() async {
    final stubNewPtr = stub.pointer;
    stub.release();
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
