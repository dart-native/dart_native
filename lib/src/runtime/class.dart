import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:ffi/ffi.dart';

class Class extends Id {
  String className;
  Class(this.className) {
    if (this.className == null) {
      this.className = 'NSObject';
    }
    
    final classNameP = Utf8.toUtf8(className);
    instance = objc_getClass(classNameP);
    // TODO: isa
    classNameP.free();
  }
}
