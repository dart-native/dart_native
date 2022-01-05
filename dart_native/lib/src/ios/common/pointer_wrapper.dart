import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';

class PointerWrapper extends NSObject {
  PointerWrapper(Pointer<Void> value) : super(Class('DNPointerWrapper')) {
    perform(SEL('setPointer:'), args: [value]);
  }

  Pointer<Void> get value => perform(SEL('pointer'));
}
