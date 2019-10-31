import 'package:dart_objc/dart_objc.dart';

class DelegateStub extends NSObject {
  DelegateStub() : super('DelegateStub', type(of: NSObject)) {
    registerDelegate(this, Selector('callback'), callback, Protocol('StubDelegate'));
  }

  callback() {
    print('callback succeed!');
  }
}