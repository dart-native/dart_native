import 'package:dart_native_example/android/runtimestub.dart';
import 'package:dart_native_example/android/entity.dart';

testAndroid(RuntimeStub stub) {
  double resultDouble = stub.getDouble(10.0);
  print('getDouble result:$resultDouble');

  String resultChar = stub.getChar('a');
  print('getChar result:$resultChar');

  int resultInt = stub.getInt(10);
  print('getInt result:$resultInt');

  bool resultBool = stub.getBool(true);
  print('getBool result:$resultBool');

  double resultFloat = stub.getFloat(10.5);
  print('getFloat result:$resultFloat');

  int resultByte = stub.getByte(1);
  print('getByte result:$resultByte');

  int resultShort = stub.getShort(1);
  print('getShort result:$resultShort');

  int resultLong = stub.getLong(100);
  print('getLong result:$resultLong');

  String resultString = stub.getString("test is success?");
  print('getString result:$resultString');

  int resultAdd = stub.add(10, 20);
  print('add result:$resultAdd');

  stub.log("testlog", "log test");

  bool resultCall = stub.complexCall("test", 10, 'a', 10.0, 12.0, 1, 2, 10000, false);
  print('call result:$resultCall');

  Entity entity = stub.createEntity();
  print('entity get time : ${entity.getCurrentTime()}');
  print('stub get time : ${stub.getTime(entity)}');
  entity.release();

  print('new entity get time : ${stub.getTime(new Entity())}');
}
