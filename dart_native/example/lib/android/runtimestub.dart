import 'package:dart_native/dart_native.dart';
class RuntimeStub extends JObject {
  RuntimeStub() : super("com/dartnative/dart_native_example/RuntimeStub");

  int getInt(int i) {
    return invoke('getInt', '(I)I', [i]);
  }

  double getDouble(double b) {
    return invoke('getDouble', '(D)D', [b]);
  }

  int getByte(int b) {
    return invoke('getByte', '(B)B', [b]);
  }

  double getFloat(double f) {
    return invoke('getFloat', '(F)F', [f]);
  }

  String getChar(String c) {
    return invoke('getChar', '(C)C', [c]);
  }

  int getShort(int s) {
    return invoke('getShort', '(S)S', [s]);
  }

  int getLong(int l) {
    return invoke('getLong', '(J)J', [l]);
  }

  bool getBool(bool b) {
    return invoke('getBool', '(Z)Z', [b]);
  }

//  JObject getObject(JObject object) {
//    return invoke('getObject', [object]);
//  }
}