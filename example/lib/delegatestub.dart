import 'package:dart_objc/dart_objc.dart';

class DelegateStub extends NSObject {
  DelegateStub() : super(Class('DelegateStub', type(of: NSObject))) {
    registerCallback(callback, 'callback', 'StubDelegate');
  }

  callback() {
    print('callback succeed!');
    return NSObject();
  }
}
