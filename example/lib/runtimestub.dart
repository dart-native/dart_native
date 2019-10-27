import 'package:dart_objc/dart_objc.dart';

class RuntimeStub extends NSObject {
  RuntimeStub() : super('RuntimeStub');

  Block fooBlock(Function func) {
    return perform(Selector('fooBlock:'), args: [func]);
  }

  CGRect fooCGRect(CGRect rect) {
    return perform(Selector('fooCGRect:'), args: [rect]);
  }
}
