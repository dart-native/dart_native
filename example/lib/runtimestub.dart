import 'package:dart_objc/dart_objc.dart';
import 'package:dart_objc_example/delegatestub.dart';

class RuntimeStub extends NSObject {
  RuntimeStub() : super('RuntimeStub');
  int selectorDuration = 0;
  int fooInt8() {
    int start1 = DateTime.now().millisecondsSinceEpoch;
    Selector sel = Selector('fooInt8:');
    selectorDuration += DateTime.now().millisecondsSinceEpoch - start1;
    return perform(sel, args: [-123]);
  }

  NSObject fooObject(NSObject object) {
    return perform(Selector('fooObject:'), args: [object]);
  }

  Block fooBlock(Function func) {
    Block result = perform(Selector('fooBlock:'), args: [func]);
    return result;
  }

  CGRect fooCGRect(CGRect rect) {
    return perform(Selector('fooCGRect:'), args: [rect]);
  }

  fooDelegate(DelegateStub delegate) {
    perform(Selector('fooDelegate:'), args: [delegate]);
  }
}
