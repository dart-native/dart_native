import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/ios/runtimestub.dart';

class DelegateStub extends NSObject with SampleDelegate {
  DelegateStub() : super(Class('DelegateStub', type(of: NSObject))) {
    super.registerSampleDelegate();
  }

  // handle notification posted from native.
  handleNotification(NSObject notification) {
    print('receive notification!');
  }

  @override
  callback() {
    print('callback succeed!');
    return 'callback';
  }

  @override
  CGRect callbackStruct(CGRect rect) {
    print('callbackStret succeed! $rect');
    return CGRect(1, 2, 3, 4);
  }
}
