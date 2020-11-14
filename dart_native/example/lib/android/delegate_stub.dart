import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/runtimestub.dart';

class DelegateStub extends JObject with SampleDelegate {
  DelegateStub([Pointer ptr])
      : super("com/dartnative/dart_native_example/SampleDelegate", ptr) {
    super.registerSampleDelegate();
  }

  @override
  callbackFloat(float f) {
    print("callback from native $f");
  }

  @override
  callbackInt(String i) {
    print("callbackInt from native $i");
  }

  @override
  callbackString(String s) {
    print("callbackString from native $s");
  }
}
