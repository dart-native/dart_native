import 'package:dart_native/dart_native.dart';

class RuntimeStub extends JObject {

//  float getFloat() {
//    return invoke('getFloat');
//  }
//
//  double getDouble() {
//    return invoke('getDouble');
//  }

  String getChar() {
    return invoke('getChar', ['a']);
  }

  int getInt() {
    return invoke('getInt', [10]);
  }

  bool getBool() {
    return invoke('getBool', [true]);
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
