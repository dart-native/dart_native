import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native
class SwiftStub extends NSObject {
  SwiftStub.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static get instance {
    Pointer<Void> resultPtr = Class('Runner.SwiftStub').perform(SEL('instance'), decodeRetVal: false);
    return SwiftStub.fromPointer(resultPtr);
  }

  String fooString(String hello) {
    return SwiftStub.instance.perform(SEL('fooString:'), args: ['Hello']);
  }

  void fooClosure(Function callback) {
    SwiftStub.instance.perform(SEL('fooClosure:'), args: [callback]);
  }
}