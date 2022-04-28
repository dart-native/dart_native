import 'dart:ffi';
import 'dart:typed_data';

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

@native(javaClass: 'com/dartnative/dart_native_example/RuntimeStub')
class RuntimeStub extends JObject {
  RuntimeStub() : super();

  RuntimeStub.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  int getInt(int i) {
    return callIntMethodSync('getInt', args: [i]);
  }

  double getDouble(double b) {
    return callDoubleMethodSync('getDouble', args: [b]);
  }

  int getByte(int b) {
    return callByteMethodSync('getByte', args: [byte(b)]);
  }

  double getFloat(double f) {
    return callFloatMethodSync('getFloat', args: [float(f)]);
  }

  int getChar(String c) {
    return callCharMethodSync('getChar', args: [jchar(c.codeUnitAt(0))]);
  }

  int getShort(int s) {
    return callShortMethodSync('getShort', args: [short(s)]);
  }

  int getLong(int l) {
    return callLongMethodSync('getLong', args: [long(l)]);
  }

  bool getBool(bool b) {
    return callBoolMethodSync('getBool', args: [b]);
  }

  String? getString(String s) {
    return callStringMethodSync('getString', args: [s]);
  }

  int add(int a, int b) {
    return callIntMethodSync('add', args: [a, b]);
  }

  void log(String a, String b) {
    return callVoidMethodSync('log', args: [a, b]);
  }

  bool complexCall(String s, int i, String c, double d, double f, int b, int sh,
      int l, bool boo) {
    return callBoolMethodSync('complexCall', args: [
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
    return callObjectMethodSync<Entity>('createEntity');
  }

  int getTime(Entity entity) {
    return callIntMethodSync('getTime', args: [entity]);
  }

  void setDelegateListener(SampleDelegate delegate) {
    callVoidMethodSync('setDelegateListener', args: [delegate]);
  }

  int getInteger() {
    return JInteger.fromPointer(
            callMethodSync("getInteger", "Ljava/lang/Integer;"))
        .raw;
  }

  List? getList(List list) {
    return callListMethodSync("getList", args: [JList(list)]);
  }

  List? getByteList(List list) {
    return callListMethodSync("getByteList", args: [JList(list)]);
  }

  List? getFloatList(List list) {
    return callListMethodSync("getFloatList", args: [JList(list)]);
  }

  List? getStringList(List list) {
    return callListMethodSync("getStringList", args: [JList(list)]);
  }

  List? getCycleList(List list) {
    return callListMethodSync("getCycleList", args: [JList(list)]);
  }

  List getByteArray(List list) {
    return JArray.fromPointer(
        callMethodSync("getByteArray", "[B", args: [JArray(list)])).raw;
  }

  Set? getIntSet(Set set) {
    return callSetMethodSync("getIntSet", args: [JHashSet(set)]);
  }

  Set? getFloatSet(Set set) {
    return callSetMethodSync("getFloatSet", args: [JHashSet(set)]);
  }

  Map? getMap(Map map) {
    return callHashMapMethodSync("getMap", args: [JHashMap(map)]);
  }

  NativeByte? getByteBuffer() {
    return callByteBufferMethodSync('getDirectByteBuffer');
  }
}
