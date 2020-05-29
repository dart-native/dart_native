import 'dart:ffi';

import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/dart_native.dart';

@native
class NativeTestClass extends NSObject {
  NativeTestClass.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
