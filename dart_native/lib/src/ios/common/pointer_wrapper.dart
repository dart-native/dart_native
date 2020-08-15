import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';

class PointerWrapper extends NSObject {
  PointerWrapper() : super(Class('DNPointerWrapper'));

  Pointer<Void> get value => perform(SEL('pointer'));
  set value(Pointer<Void> ptr) {
    perform(SEL('setPointer:'), args: [ptr]);
  }
}
