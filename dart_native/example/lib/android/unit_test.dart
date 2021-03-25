import 'package:dart_native_example/android/delegate_stub.dart';
import 'package:dart_native_example/android/runtimestub.dart';
import 'package:dart_native_example/android/entity.dart';
import 'package:dart_native/dart_native.dart';

testAndroid(RuntimeStub stub) {
  int ms = currentTimeMillis();
  double resultDouble = stub.getDouble(10.0);
  int use = currentTimeMillis() - ms;
  print('getDouble result:$resultDouble , cost:$use');

  ms = currentTimeMillis();
  String resultChar = stub.getChar('a');
  use = currentTimeMillis() - ms;
  print('getChar result:$resultChar , cost:$use');

  ms = currentTimeMillis();
  int resultInt = stub.getInt(10);
  use = currentTimeMillis() - ms;
  print('getInt result:$resultInt , cost:$use');

  ms = currentTimeMillis();
  bool resultBool = stub.getBool(true);
  use = currentTimeMillis() - ms;
  print('getBool result:$resultBool , cost:$use');

  ms = currentTimeMillis();
  double resultFloat = stub.getFloat(10.5);
  use = currentTimeMillis() - ms;
  print('getFloat result:$resultFloat , cost:$use');

  ms = currentTimeMillis();
  int resultByte = stub.getByte(1);
  use = currentTimeMillis() - ms;
  print('getByte result:$resultByte , cost:$use');

  ms = currentTimeMillis();
  int resultShort = stub.getShort(1);
  use = currentTimeMillis() - ms;
  print('getShort result:$resultShort , cost:$use');

  ms = currentTimeMillis();
  int resultLong = stub.getLong(100);
  use = currentTimeMillis() - ms;
  print('getLong result:$resultLong , cost:$use');

  ms = currentTimeMillis();
  String resultString = stub.getString("test is success?");
  use = currentTimeMillis() - ms;
  print('getString result:$resultString, cost:$use');

  ms = currentTimeMillis();
  int resultAdd = stub.add(10, 20);
  use = currentTimeMillis() - ms;
  print('add result:$resultAdd, cost:$use');

  ms = currentTimeMillis();
  stub.log("testlog", "log test");
  use = currentTimeMillis() - ms;
  print('testlog, cost:$use');

  bool resultCall = stub.complexCall(
      "test",
      10,
      'a',
      10.0,
      12.0,
      1,
      2,
      10000,
      false);
  print('call result:$resultCall');

  Entity entity = stub.createEntity();
  print('entity get time : ${entity.getCurrentTime()}');
  print('stub get time : ${stub.getTime(entity)}');

  print('new entity get time : ${stub.getTime(new Entity())}');

  stub.setDelegateListener(DelegateStub());

  print("integer ${stub.getInteger()}");

  JList jList1 = JList([1, 2, 3, 4]);
  List list = stub.getList(jList1);
  for (int item in list) {
    print("item $item");
  }
}

int currentTimeMillis() {
  return new DateTime.now().millisecondsSinceEpoch;
}
