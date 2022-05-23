import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/ios/runtimestub.dart';

extension RuntimeStubAsync on RuntimeStub {
  Future<String> fooNSStringAsync(String str) async {
    return perform(SEL('fooNSString:'), args: [str]).then((value) {
      return NSString.fromPointer(value.pointer).raw;
    });
  }
}
