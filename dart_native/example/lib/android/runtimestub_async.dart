import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/runtimestub.dart';

extension RuntimeStubAsync on RuntimeStub {
  Future<String> getStringAsync(String s) async {
    return invokeAsync('getString', [s], "Ljava/lang/String;",
            thread: Thread.MainThread)
        .then((value) => value);
  }
}
