import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

/// invoke extension simplify invoke function
/// don't need return type's signature when calling invoke
extension JObjectInvoke on JObject {
  /// invoke native method which return int
  int invokeInt(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'I',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return byte
  int invokeByte(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'B',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return short
  int invokeShort(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'S',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return char
  int invokeChar(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'C',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return long
  int invokeLong(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'J',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return float
  double invokeFloat(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'F',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return double
  double invokeDouble(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'D',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return bool
  bool invokeBool(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'Z',
        args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return void
  void invokeVoid(String methodName,
      {List? args, List<String>? assignedSignature}) {
    invoke(methodName, 'V', args: args, assignedSignature: assignedSignature);
  }

  /// invoke native method which return string
  String? invokeString(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'Ljava/lang/String;',
        args: args, assignedSignature: assignedSignature);
  }

  dynamic invokeObject<T extends JObject>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    String type = T.toString();
    if (type == 'dynamic') {
      throw 'invokeObject error. \n' +
          'Using invokeObject need specify the dart type.\n' +
          'And this dart class need extend jobject. \n' +
          'For example: invokeObject<JInteger>("getTest");';
    }
    final sig = getRegisterJavaClassSignature(type);
    if (sig == null) {
      throw 'invokeObject error. \n' +
          'Can not find signature in register map.\n' +
          'You should use @nativeJavaClass specify the java class.' +
          'See more in https://github.com/dart-native/dart_native/tree/master#usage.\n' +
          'Or you can just use invoke method to specify the return type,' +
          'like invoke("getString", "Ljava/lang/String;")';
    }
    final convertor = getRegisterPointerConvertor(type);
    return convertor!(invoke(methodName, sig,
        args: args, assignedSignature: assignedSignature));
  }

  /// invoke native method which return list
  List<E>? invokeList<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = invoke(methodName, 'Ljava/util/List;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// invoke native method which return array list
  List<E>? invokeArrayList<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = invoke(methodName, 'Ljava/util/ArrayList;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JArrayList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// invoke native method which return set
  Set<E>? invokeSet<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = invoke(methodName, 'Ljava/util/Set;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// invoke native method which return hash set
  Set<E>? invokeHashSet<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = invoke(methodName, 'Ljava/util/HashSet;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JHashSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// invoke native method which return map
  Map<K, V>? invokeMap<K, V>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = invoke(methodName, 'Ljava/util/Map;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }

  /// invoke native method which return hash map
  Map<K, V>? invokeHashMap<K, V>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = invoke(methodName, 'Ljava/util/HashMap;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JHashMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }
}
