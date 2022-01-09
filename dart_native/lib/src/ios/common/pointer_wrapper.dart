import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/message.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';

class PointerWrapper extends NSObject {
  PointerWrapper(Pointer<Void> value) : super.fromPointer(_initWithPointer(value));

  Pointer<Void> get value => perform(SEL('pointer'));

  static Pointer<Void> _initWithPointer(Pointer<Void> pointer) {
    Pointer<Void> target = alloc(Class('DNPointerWrapper'));
    SEL sel = 'initWithPointer:'.toSEL();
    return msgSend(target, sel, args: [pointer], decodeRetVal: false);
  }
}
