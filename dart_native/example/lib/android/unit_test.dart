import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/delegate_stub.dart';
import 'package:dart_native_example/android/runtimestub.dart';
import 'package:dart_native_example/android/entity.dart';
import 'package:dart_native_example/android/runtimestub_async.dart';

import 'delegate_stub.dart';
import 'package:dart_native_example/dn_unit_test.dart';
import 'package:ffi/ffi.dart';

/// Android unit test implementation.
class DNAndroidUnitTest with DNUnitTestBase {
  final stub = RuntimeStub();

  @override
  Future<void> runAllUnitTests() async {
    await testAndroid(stub);
  }
}

testAndroid(RuntimeStub stub) async {
  int ms = currentTimeMillis();
  double resultDouble = stub.getDouble(3.40282e+038);
  int use = currentTimeMillis() - ms;
  print('getDouble result:$resultDouble , cost:$use');

  ms = currentTimeMillis();
  int resultChar = stub.getChar('a');
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
  int resultLong = stub.getLong(4294967296);
  use = currentTimeMillis() - ms;
  print('getLong result:$resultLong , cost:$use');

  ms = currentTimeMillis();
  String? resultString = stub.getString("test is success?");
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

  bool resultCall =
      stub.complexCall("test", 10, 'a', 10.0, 12.0, 1, 2, 10000, false);
  print('call result:$resultCall');

  Entity entity = stub.createEntity();
  print('entity get time : ${entity.getCurrentTime()}');
  print('stub get time : ${stub.getTime(entity)}');

  print('new entity get time : ${stub.getTime(Entity())}');

  List? list = stub.getList([1, 2, 3, 4]);
  if (list != null) {
    for (int item in list) {
      print("item $item");
    }
  }

  list = stub.getByteList(
      [const byte(1), const byte(2), const byte(3), const byte(4)]);
  if (list != null) {
    for (int item in list) {
      print("item $item");
    }
  }

  list = stub.getFloatList(
      [const float(1.0), const float(2.0), const float(3.0), const float(4.0)]);
  if (list != null) {
    for (double item in list) {
      print("item $item");
    }
  }

  list = stub.getCycleList([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ]);
  if (list != null) {
    for (List items in list) {
      for (int item in items) {
        print("item $item");
      }
    }
  }

  List byteArray =
      stub.getByteArray([const byte(1), const byte(2), const byte(3)]);
  for (int byte in byteArray) {
    print("item $byte");
  }

  Set? intSet = stub.getIntSet({1, 2, 3});
  if (intSet != null) {
    for (int setInt in intSet) {
      print("intSet $setInt");
    }
  }

  Set? fSet =
      stub.getFloatSet({const float(1.0), const float(2.0), const float(4.0)});
  if (fSet != null) {
    for (double setF in fSet) {
      print("fSet $setF");
    }
  }

  Map? map = stub.getMap({"1": 10, "2": 20, "3": 30});
  if (map != null) {
    map.forEach((key, value) {
      print("map from native $key : $value");
    });
  }

  List? strList = stub.getStringList(["test啊 emoji🤣", "emoji🤣"]);
  if (strList != null) {
    for (var item in strList) {
      print("item $item");
    }
  }

  stub.setDelegateListener(DelegateStub());

  print(
      "getStringAsync ${await stub.getStringAsync('This is a long string: sdlfdksjflksndhiofuu2893873(*（%￥#@）*&……￥撒肥料开发时傅雷家书那份会计师东方丽景三等奖')}");

  final buffer = stub.getByteBuffer();
  print(
      "get direct byte buffer result ${buffer.bytes.cast<Utf8>().toDartString(length: buffer.lengthInBytes)}");
}

int currentTimeMillis() {
  return DateTime.now().millisecondsSinceEpoch;
}
