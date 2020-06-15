import 'package:dart_native_example/android/runtimestub.dart';

testAndroid(RuntimeStub stub) {

  String resultString = stub.getString("test is success?");
  print('getString1 result:$resultString');

}
