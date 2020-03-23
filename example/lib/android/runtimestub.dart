import 'package:dart_native/dart_native.dart';

class RuntimeStub extends JObject {

//  float getFloat() {
//    return invoke('getFloat');
//  }
//
//  double getDouble() {
//    return invoke('getDouble');
//  }

  void getInt() {
    return invoke('getChar', ['200dc']);
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
