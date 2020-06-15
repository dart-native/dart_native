import 'package:dart_native/dart_native.dart';

class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  String getString(String s) {
    nativeInvoke();
  }
}
