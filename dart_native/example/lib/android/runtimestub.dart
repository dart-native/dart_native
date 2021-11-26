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

  String getString(String s) {
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
    return Entity.fromPointer(invoke(
        'createEntity', "Lcom/dartnative/dart_native_example/Entity;"));
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

  List getList(List list) {
    JList jl = JList(list);
    return JList.fromPointer(invoke("getList", "Ljava/util/List;", args: [jl])).raw;
  }

  List getByteList(List list) {
    JList jl = JList(list);
    return JList.fromPointer(invoke("getByteList", "Ljava/util/List;", args: [jl]))
        .raw;
  }

  List getFloatList(List list) {
    JList jl = JList(list);
    return JList.fromPointer(invoke("getFloatList", "Ljava/util/List;", args: [jl]))
        .raw;
  }

  List getStringList(List list) {
    JList jl = JList(list);
    return JList.fromPointer(invoke("getStringList", "Ljava/util/List;", args: [jl]))
        .raw;
  }

  List getCycleList(List list) {
    JList jl = JList(list);
    return JList.fromPointer(invoke("getCycleList", "Ljava/util/List;", args: [jl]))
        .raw;
  }

  List getByteArray(List list) {
    return JArray.fromPointer(invoke("getByteArray", "[B", args: [JArray(list)])).raw;
  }

  Set getIntSet(Set set) {
    return JSet.fromPointer(
            invoke("getIntSet", "Ljava/util/Set;", args: [JHashSet(set)]))
        .raw;
  }

  Set getFloatSet(Set set) {
    return JSet.fromPointer(
            invoke("getFloatSet", "Ljava/util/Set;", args: [JHashSet(set)]))
        .raw;
  }

  Map getMap(Map map) {
    return JHashMap.fromPointer(
            invoke("getMap", "Ljava/util/HashMap;", args: [JHashMap(map)]))
        .raw;
  }
}
