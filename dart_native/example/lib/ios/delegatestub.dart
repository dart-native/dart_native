import 'package:dart_native/dart_native.dart';

abstract class SampleDelegate implements BasicProtocol {
  register() {
    registerProtocolCallback(this, callback, 'callback', SampleDelegate);
    registerProtocolCallback(this, callbackStruct, 'callbackStruct:', SampleDelegate);
  }
  callback();
  CGRect callbackStruct(CGRect rect);
}

class DelegateStub extends NSObject with SampleDelegate {
  DelegateStub() : super(Class('DelegateStub', type(of: NSObject))) {
    super.register();
  }

  handleNotification(NSObject notification) {
    print('receive notification!');
  }

  @override
  callback() {
    print('callback succeed!');
    return NSObject();
  }

  @override
  CGRect callbackStruct(CGRect rect) {
    print('callbackStret succeed! $rect');
    return CGRect(1, 2, 3, 4);
  }
}
