import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/functions.dart';

class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  String getString(String s) {
    nativeInvoke(["xxxx"]);
  }
}
