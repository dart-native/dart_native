import 'package:dart_objc/dart_objc.dart';
import 'package:dart_objc_example/delegatestub.dart';

class RuntimeStub extends NSObject {
  RuntimeStub() : super('RuntimeStub');

  Block fooBlock(Function func) {
    Block block = Block(func);
    Block result = perform(Selector('fooBlock:'), args: [block]);
    block.release();
    return result;
  }

  CGRect fooCGRect(CGRect rect) {
    return perform(Selector('fooCGRect:'), args: [rect]);
  }

  fooDelegate(DelegateStub delegate) {
    return perform(Selector('fooDelegate:'), args: [delegate]);
  }
}
