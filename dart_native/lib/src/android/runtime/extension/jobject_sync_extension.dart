import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

/// call extension simplify call function
/// don't need return type's signature when calling native method
extension JObjectSyncCallMethod on JObject {
  /// call native method which return int
  int callIntMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'I',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return byte
  int callByteMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'B',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return short
  int callShortMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'S',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return char
  int callCharMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'C',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return long
  int callLongMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'J',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return float
  double callFloatMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'F',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return double
  double callDoubleMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'D',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return bool
  bool callBoolMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'Z',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return void
  void callVoidMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    callMethodSync(methodName, 'V',
        args: args, assignedSignature: assignedSignature);
  }

  /// call native method which return string
  String? callStringMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'Ljava/lang/String;',
        args: args, assignedSignature: assignedSignature);
  }

  dynamic callObjectMethodSync<T extends JObject>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    String type = T.toString();
    if (type == 'dynamic') {
      throw 'callObject error. \n'
          'Using callObject need specify the dart type.\n'
          'And this dart class need extend jobject. \n'
          'For example: callObject<JInteger>("getTest");';
    }
    final sig = getRegisterJavaClassSignature(type);
    if (sig == null) {
      throw 'callObject error. \n'
          'Can not find signature in register map.\n'
          'You should use @nativeJavaClass specify the java class.'
          'See more in https://github.com/dart-native/dart_native/tree/master#usage.\n'
          'Or you can just use call method to specify the return type,'
          'like call("getString", "Ljava/lang/String;")';
    }
    final convertor = getRegisterPointerConvertor(type);
    return convertor!(callMethodSync(methodName, sig,
        args: args, assignedSignature: assignedSignature));
  }

  /// call native method which return list
  List<E>? callListMethodSync<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = callMethodSync(methodName, 'Ljava/util/List;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// call native method which return array list
  List<E>? callArrayListMethodSync<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = callMethodSync(methodName, 'Ljava/util/ArrayList;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JArrayList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// call native method which return set
  Set<E>? callSetMethodSync<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = callMethodSync(methodName, 'Ljava/util/Set;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// call native method which return hash set
  Set<E>? callHashSetMethodSync<E>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = callMethodSync(methodName, 'Ljava/util/HashSet;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JHashSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// call native method which return map
  Map<K, V>? callMapMethodSync<K, V>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = callMethodSync(methodName, 'Ljava/util/Map;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }

  /// call native method which return hash map
  Map<K, V>? callHashMapMethodSync<K, V>(String methodName,
      {List? args, List<String>? assignedSignature}) {
    final ptr = callMethodSync(methodName, 'Ljava/util/HashMap;',
        args: args, assignedSignature: assignedSignature);
    if (ptr == nullptr) {
      return null;
    }
    return JHashMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }

  /// call native method which return DirectByteBuffer
  NativeByte? callByteBufferMethodSync(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return callMethodSync(methodName, 'Ljava/nio/ByteBuffer;',
        args: args, assignedSignature: assignedSignature);
  }
}
