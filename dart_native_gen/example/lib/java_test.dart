import 'dart:ffi';

import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/dart_native.dart';

@nativeJavaClass('com/dartnative/test')
class JavaCls extends JObject {
  JavaCls.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}