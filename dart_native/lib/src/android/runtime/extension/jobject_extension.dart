import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

/// call async extension simplify call function
/// don't need return type's signature when calling native method
extension JObjectCallMethod on JObject {
  /// async call native  method which return int
  Future<int> callIntMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'I',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return byte
  Future<int> callByteMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'B',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return short
  Future<int> callShortMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'S',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return char
  Future<int> callCharMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'C',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return long
  Future<int> callLongMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'J',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return float
  Future<double> callFloatMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'F',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return double
  Future<double> callDoubleMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'D',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return bool
  Future<bool> callBoolMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'Z',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return void
  void callVoidMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    callMethod(methodName, 'V',
        args: args, assignedSignature: assignedSignature, thread: thread);
  }

  /// async call native method which return string
  Future<String>? callStringMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'Ljava/lang/String;',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async call native method which return object
  Future<dynamic> callObjectMethod<T extends JObject>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
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
    return callMethod(methodName, sig,
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => convertor!(value));
  }

  /// async call native method which return list
  Future<List<E>?> callListMethod<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    final ptr = await callMethod(methodName, 'Ljava/util/List;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async call native method which return array list
  Future<List<E>?> callArrayListMethod<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    final ptr = await callMethod(methodName, 'Ljava/util/ArrayList;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JArrayList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async call native method which return set
  Future<Set<E>?> callSetMethod<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    final ptr = await callMethod(methodName, 'Ljava/util/Set;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async call native method which return hash set
  Future<Set<E>?> callHashSetMethod<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    final ptr = await callMethod(methodName, 'Ljava/util/HashSet;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JHashSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async call native method which return map
  Future<Map<K, V>?> callMapMethod<K, V>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    final ptr = await callMethod(methodName, 'Ljava/util/Map;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }

  /// async call native method which return hash map
  Future<Map<K, V>?> callHashMapMethod<K, V>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    final ptr = await callMethod(methodName, 'Ljava/util/HashMap;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JHashMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }

  /// async call native method which return DirectByteBuffer
  Future<NativeByte?> callByteBufferMethod(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return callMethod(methodName, 'Ljava/nio/ByteBuffer;',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }
}
