import 'package:dart_native/dart_native.dart';

class RuntimeStub extends JObject {
  double getFloat() {
    return invoke('getFloat', [8.65], true);
  }

  double getDouble() {
    return invoke('getDouble', [10.22]);
  }

  String getChar() {
    return invoke('getChar', ['a']);
  }

  int getInt() {
    return invoke('getInt', [10]);
  }

  bool getBool() {
    return invoke('getBool', [true]);
  }

  void setJavaTargetClass(String className) {
    setTargetClass(className);
  }

//  int getByte() {
//    return invoke('getByte');
//  }
//
//  int getShort() {
//    return invoke('getShort');
//  }
//
//  int getLong() {
//    return invoke('getLong');
//  }
//
//  int getChar() {
//    return invoke('getChar');
//  }
}
