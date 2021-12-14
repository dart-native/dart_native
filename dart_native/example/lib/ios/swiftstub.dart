import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native()
class SwiftStub extends NSObject {
  static final _objcClassName = 'Runner.SwiftStub';
  SwiftStub([Class? isa]) : super(isa ?? Class(_objcClassName));
  SwiftStub.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static get instance {
    Pointer<Void> resultPtr = Class(_objcClassName).perform(SEL('instance'), decodeRetVal: false);
    return SwiftStub.fromPointer(resultPtr);
  }

  get sideLength {
    return perform(SEL('sideLength'));
  }

  set sideLength(newValue) {
    perform(SEL('setSideLength:'), args: [newValue]);
  }

  get perimeter {
    return perform(SEL('perimeter'));
  }

  set perimeter(newValue) {
    perform(SEL('setPerimeter:'), args: [newValue]);
  }

  String fooString(String hello) {
    return SwiftStub.instance.perform(SEL('fooString:'), args: ['Hello']);
  }

  void fooClosure(Function callback) {
    SwiftStub.instance.perform(SEL('fooClosure:'), args: [callback]);
  }
}