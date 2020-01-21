import 'package:dart_native/dart_native.dart';

abstract class SampleDelegate {
  callback();
  callbackStret();
}

class DelegateStub extends NSObject implements SampleDelegate {
  DelegateStub() : super(Class('DelegateStub', type(of: NSObject))) {
    registerProtocolCallback(callback, 'callback', SampleDelegate);
    registerProtocolCallback(callbackStret, 'callbackStret', SampleDelegate);
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
  callbackStret() {
    print('callbackStret succeed!');
    return CGRect(1, 2, 3, 4);
  }
}
