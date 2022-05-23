import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native()
class SwiftStub extends NSObject {
  static const _objcClassName = 'Runner.SwiftStub';
  SwiftStub([Class? isa]) : super(isa ?? Class(_objcClassName));
  SwiftStub.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static get instance {
    Pointer<Void> resultPtr =
        Class(_objcClassName).performSync(SEL('instance'), decodeRetVal: false);
    return SwiftStub.fromPointer(resultPtr);
  }

  get sideLength {
    return performSync(SEL('sideLength'));
  }

  set sideLength(newValue) {
    performSync(SEL('setSideLength:'), args: [newValue]);
  }

  get perimeter {
    return performSync(SEL('perimeter'));
  }

  set perimeter(newValue) {
    performSync(SEL('setPerimeter:'), args: [newValue]);
  }

  String fooString(String hello) {
    return SwiftStub.instance.performSync(SEL('fooString:'), args: ['Hello']);
  }

  void fooClosure(Function callback) {
    SwiftStub.instance.performSync(SEL('fooClosure:'), args: [callback]);
  }
}
