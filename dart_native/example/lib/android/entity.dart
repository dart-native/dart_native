import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native(javaClass: 'com/dartnative/dart_native_example/Entity')
class Entity extends JObject {
  Entity() : super();

  Entity.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  int getCurrentTime() {
    return callMethodSync('getCurrentTime', "I", args: []);
  }
}
