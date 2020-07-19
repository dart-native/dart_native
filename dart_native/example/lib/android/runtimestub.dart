import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/entity.dart';

class RuntimeStub extends JObject {
  RuntimeStub([Pointer ptr]) : super("com/dartnative/dart_native_example/RuntimeStub", ptr);

  int getInt(int i) {
    return invoke('getInt', [i], "I");
  }

  double getDouble(double b) {
    return invoke('getDouble', [b], "D");
  }

  int getByte(int b) {
    return invoke('getByte', [b], "B");
  }

  double getFloat(double f) {
    return invoke('getFloat', [f], "F");
  }

  String getChar(String c) {
    return invoke('getChar', [c], "C");
  }

  int getShort(int s) {
    return invoke('getShort', [s], "S");
  }

  int getLong(int l) {
    return invoke('getLong', [l], "J");
  }

  bool getBool(bool b) {
    return invoke('getBool', [b], "Z");
  }

  String getString(String s) {
    return invoke('getString', [s], "Ljava/lang/String;");
  }

  int add(int a, int b) {
    return invoke('add', [a, b], "I");
  }

  void log(String a, String b) {
    return invoke('log', [a, b], "V");
  }
//
//  bool complexCall(String s, int i, String c, double d, double f, int b, int sh, int l, bool boo) {
//    return invoke('complexCall', '(Ljava/lang/String;ICDFBSJZ)Z', [s, i, c, d, f, b, sh, l, boo]);
//  }
//
  Entity createEntity() {
    return new Entity(invoke('createEntity', [], "Lcom/dartnative/dart_native_example/Entity;"));
  }

  int getTime(Entity entity) {
    return invoke('getTime', [entity], "I");
  }
}
