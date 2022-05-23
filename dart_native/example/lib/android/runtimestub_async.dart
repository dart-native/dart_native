import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/runtimestub.dart';

extension RuntimeStubAsync on RuntimeStub {
  Future<String> getStringAsync(String s) async {
    return callMethod('getString', "Ljava/lang/String;",
            args: [s], thread: Thread.mainThread)
        .then((value) => value);
  }
}
