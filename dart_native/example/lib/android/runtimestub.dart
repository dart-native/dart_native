import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/entity.dart';

abstract class SampleDelegate {
  registerSampleDelegate() {
    registerCallback(this, callbackInt, 'callbackInt');
    registerCallback(this, callbackFloat, 'callbackFloat');
    registerCallback(this, callbackString, 'callbackString');
    registerCallback(this, callbackDouble, 'callbackDouble');
    registerCallback(this, callbackComplex, 'callbackComplex');
  }
  callbackInt(int i);
  callbackFloat(double f);
  callbackString(String s);
  callbackDouble(double d);
  callbackComplex(int i, double d, String s);
}

class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  int getInt(int i) {
    return invoke('getInt', [i], "I");
  }

  double getDouble(double b) {
    return invoke('getDouble', [b], "D");
  }

  int getByte(int b) {
    return invoke('getByte', [byte(b)], "B");
  }

  double getFloat(double f) {
    return invoke('getFloat', [float(f)], "F");
  }

  String getChar(String c) {
    return invoke('getChar', [char(c.codeUnitAt(0))], "C");
  }

  int getShort(int s) {
    return invoke('getShort', [short(s)], "S");
  }

  int getLong(int l) {
    return invoke('getLong', [long(l)], "J");
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

  bool complexCall(String s, int i, String c, double d, double f, int b, int sh, int l, bool boo) {
    return invoke('complexCall', [s, i, char(c.codeUnitAt(0)), d, float(f), byte(b), short(sh), long(l), boo], "Z");
  }

  Entity createEntity() {
    return new Entity(invoke('createEntity', [], "Lcom/dartnative/dart_native_example/Entity;"));
  }

  int getTime(Entity entity) {
    return invoke('getTime', [entity], "I");
  }

  void setDelegateListener(SampleDelegate delegate) {
    invoke('setDelegateListener', [delegate], "V");
  }

  int getInteger() {
    return Integer.fromPointer(invoke("getInteger", null, "Ljava/lang/Integer;")).raw;
  }

  List getList(JList list) {
    return JList.fromPointer(invoke("getList", [list], "Ljava/util/List;")).raw;
  }

}
