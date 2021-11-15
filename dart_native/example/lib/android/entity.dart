import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

class Entity extends JObject {
  Entity([Pointer<Void>? ptr])
      : super("com/dartnative/dart_native_example/Entity", pointer: ptr);

  int getCurrentTime() {
    return invoke('getCurrentTime', [], "I");
  }
}
