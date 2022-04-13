import 'dart:ffi';

import 'package:dart_native/src/darwin/runtime/class.dart';
import 'package:dart_native/src/darwin/runtime/message.dart';
import 'package:dart_native/src/darwin/runtime/nsobject.dart';
import 'package:dart_native/src/darwin/runtime/selector.dart';

class PointerWrapper extends NSObject {
  PointerWrapper(Pointer<Void> value) : super.fromPointer(_initWithPointer(value));

  Pointer<Void> get value => perform(SEL('pointer'));

  static Pointer<Void> _initWithPointer(Pointer<Void> pointer) {
    Pointer<Void> target = alloc(Class('DNPointerWrapper'));
    SEL sel = 'initWithPointer:'.toSEL();
    return msgSend(target, sel, args: [pointer], decodeRetVal: false);
  }
}
