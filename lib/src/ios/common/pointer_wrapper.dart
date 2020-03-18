import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';

class PointerWrapper extends NSObject {
  PointerWrapper([this._pointerDealloc]) : super(Class('DNPointerWrapper'));
  // Using for calling pointer's Dart class dealloc.
  Function _pointerDealloc;

  Pointer<Void> get value => perform(SEL('pointer'));
  set value(Pointer<Void> ptr) {
    perform(SEL('setPointer:'), args: [ptr]);
  }

  @override
  dealloc() {
    if (_pointerDealloc != null) {
      _pointerDealloc();
    }
    return super.dealloc();
  }
}
