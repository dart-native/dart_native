import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

extension JObjectInvoke on JObject {
  T invokeObject<T extends JObject>(
      String methodName, T Function(Pointer<Void>) creator,
      {List? args, String? returnType, List<String>? assignedSignature}) {
    Pointer<Void> ptr = invoke(
        methodName, returnType == null ? (T as JObject).clsName : returnType,
        args: args, assignedSignature: assignedSignature);
    return creator(ptr);
  }

  int invokeInt(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'I',
        args: args, assignedSignature: assignedSignature);
  }

  int invokeByte(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'B',
        args: args, assignedSignature: assignedSignature);
  }

  int invokeShort(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'S',
        args: args, assignedSignature: assignedSignature);
  }

  int invokeChar(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'C',
        args: args, assignedSignature: assignedSignature);
  }

  int invokeLong(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'J',
        args: args, assignedSignature: assignedSignature);
  }

  double invokeFloat(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'F',
        args: args, assignedSignature: assignedSignature);
  }

  double invokeDouble(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'D',
        args: args, assignedSignature: assignedSignature);
  }

  bool invokeBool(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'Z',
        args: args, assignedSignature: assignedSignature);
  }

  void invokeVoid(String methodName,
      {List? args, List<String>? assignedSignature}) {
    invoke(methodName, 'V', args: args, assignedSignature: assignedSignature);
  }

  String invokeString(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, 'Ljava/lang/String;',
        args: args, assignedSignature: assignedSignature);
  }
}
