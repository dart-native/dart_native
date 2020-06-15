import 'package:dart_native_example/android/runtimestub.dart';

testAndroid(RuntimeStub stub) {

  String resultString = stub.getInt(123);
  print('getString result:$resultString');
}
