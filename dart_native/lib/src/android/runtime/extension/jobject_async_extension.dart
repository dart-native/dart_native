import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

/// invoke async extension simplify invoke function
/// don't need return type's signature when calling invoke
extension JObjectAsyncInvoke on JObject {
  /// async invoke native  method which return int
  Future<int> invokeAsyncInt(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'I',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return byte
  Future<int> invokeAsyncByte(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'B',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return short
  Future<int> invokeAsyncShort(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'S',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return char
  Future<int> invokeAsyncChar(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'C',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return long
  Future<int> invokeAsyncLong(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'J',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return float
  Future<double> invokeAsyncFloat(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'F',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return double
  Future<double> invokeAsyncDouble(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'D',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return bool
  Future<bool> invokeAsyncBool(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'Z',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return void
  void invokeAsyncVoid(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    invokeAsync(methodName, 'V',
        args: args, assignedSignature: assignedSignature, thread: thread);
  }

  /// async invoke native method which return string
  Future<String>? invokeAsyncString(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeAsync(methodName, 'Ljava/lang/String;',
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => value);
  }

  /// async invoke native method which return object
  Future<dynamic> invokeAsyncObject<T extends JObject>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
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
    return invokeAsync(methodName, sig,
            args: args, assignedSignature: assignedSignature, thread: thread)
        .then((value) => convertor!(value));
  }

  /// async invoke native method which return list
  Future<List<E>?> invokeAsyncList<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    final ptr = await invokeAsync(methodName, 'Ljava/util/List;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async invoke native method which return array list
  Future<List<E>?> invokeAsyncArrayList<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    final ptr = await invokeAsync(methodName, 'Ljava/util/ArrayList;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JArrayList<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async invoke native method which return set
  Future<Set<E>?> invokeAsyncSet<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    final ptr = await invokeAsync(methodName, 'Ljava/util/Set;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async invoke native method which return hash set
  Future<Set<E>?> invokeAsyncHashSet<E>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    final ptr = await invokeAsync(methodName, 'Ljava/util/HashSet;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JHashSet<E>.fromPointer(ptr).raw.cast<E>();
  }

  /// async invoke native method which return map
  Future<Map<K, V>?> invokeAsyncMap<K, V>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    final ptr = await invokeAsync(methodName, 'Ljava/util/Map;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }

  /// async invoke native method which return hash map
  Future<Map<K, V>?> invokeAsyncHashMap<K, V>(String methodName,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    final ptr = await invokeAsync(methodName, 'Ljava/util/HashMap;',
        args: args, assignedSignature: assignedSignature, thread: thread);
    if (ptr == nullptr) {
      return null;
    }
    return JHashMap<K, V>.fromPointer(ptr).raw.cast<K, V>();
  }
}
