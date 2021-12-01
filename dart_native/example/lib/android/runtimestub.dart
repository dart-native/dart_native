import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/entity.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

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

@nativeJavaClass('com/dartnative/dart_native_example/RuntimeStub')
class RuntimeStub extends JObject {
  RuntimeStub(): super();

  RuntimeStub.fromPointer(Pointer<Void> ptr): super.fromPointer(ptr);

  int getInt(int i) {
    return invokeInt('getInt', args: [i]);
  }

  double getDouble(double b) {
    return invokeDouble('getDouble', args: [b]);
  }

  int getByte(int b) {
    return invokeByte('getByte', args: [byte(b)]);
  }

  double getFloat(double f) {
    return invokeFloat('getFloat', args: [float(f)]);
  }

  int getChar(String c) {
    return invokeChar('getChar', args: [jchar(c.codeUnitAt(0))]);
  }

  int getShort(int s) {
    return invokeShort('getShort', args: [short(s)]);
  }

  int getLong(int l) {
    return invokeLong('getLong', args: [long(l)]);
  }

  bool getBool(bool b) {
    return invokeBool('getBool', args: [b]);
  }

  String? getString(String s) {
    return invokeString('getString', args: [s]);
  }

  int add(int a, int b) {
    return invokeInt('add', args: [a, b]);
  }

  void log(String a, String b) {
    return invokeVoid('log', args: [a, b]);
  }

  bool complexCall(String s, int i, String c, double d, double f, int b, int sh,
      int l, bool boo) {
    return invokeBool(
        'complexCall',
        args: [
          s,
          i,
          jchar(c.codeUnitAt(0)),
          d,
          float(f),
          byte(b),
          short(sh),
          long(l),
          boo
        ]);
  }

  Entity createEntity() {
    return invokeObject<Entity>('createEntity');
  }

  int getTime(Entity entity) {
    return invokeInt('getTime', args: [entity]);
  }

  void setDelegateListener(SampleDelegate delegate) {
    invokeVoid('setDelegateListener', args: [delegate]);
  }

  int getInteger() {
    return JInteger.fromPointer(
            invoke("getInteger", "Ljava/lang/Integer;"))
        .raw;
  }

  List? getList(List list) {
    return invokeList("getList", args: [JList(list)]);
  }

  List? getByteList(List list) {
    return invokeList("getByteList", args: [JList(list)]);
  }

  List? getFloatList(List list) {
    return invokeList("getFloatList", args: [JList(list)]);
  }

  List? getStringList(List list) {
    return invokeList("getStringList", args: [JList(list)]);
  }

  List? getCycleList(List list) {
    return invokeList("getCycleList", args: [JList(list)]);
  }

  List getByteArray(List list) {
    return JArray.fromPointer(invoke("getByteArray", "[B", args: [JArray(list)])).raw;
  }

  Set? getIntSet(Set set) {
    return invokeSet("getIntSet", args: [JHashSet(set)]);
  }

  Set? getFloatSet(Set set) {
    return invokeSet("getFloatSet", args: [JHashSet(set)]);
  }

  Map? getMap(Map map) {
    return invokeHashMap("getMap", args: [JHashMap(map)]);
  }
}
