import 'package:dart_native/dart_native.dart';

abstract class SampleDelegate {
  callback();
  CGRect callbackStruct(CGRect rect);
}

class DelegateStub extends NSObject implements SampleDelegate {
  DelegateStub() : super(Class('DelegateStub', type(of: NSObject))) {
    registerProtocolCallback(callback, 'callback', SampleDelegate);
    registerProtocolCallback(callbackStruct, 'callbackStruct:', SampleDelegate);
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
