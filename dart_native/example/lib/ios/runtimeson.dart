import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'runtimestub.dart';

@native
class RuntimeSon extends RuntimeStub {
  RuntimeSon([Class isa]) : super(isa ?? Class('RuntimeSon'));
  RuntimeSon.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
