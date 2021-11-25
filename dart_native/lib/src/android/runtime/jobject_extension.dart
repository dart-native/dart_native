import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

extension JObjectInvoke on JObject {
  T invokeObject<T extends JObject>(
      String methodName, T Function(Pointer<Void>) creator,
      {List? args, String? returnType, List<String>? assignedSignature}) {
    Pointer<Void> ptr = invoke(methodName, args,
        returnType == null ? (T as JObject).clsName : returnType,
        assignedSignature: assignedSignature);
    return creator(ptr);
  }

  int invokeInt(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'I', assignedSignature: assignedSignature);
  }

  int invokeByte(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'B', assignedSignature: assignedSignature);
  }

  int invokeShort(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'S', assignedSignature: assignedSignature);
  }

  int invokeChar(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'C', assignedSignature: assignedSignature);
  }

  int invokeLong(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'J', assignedSignature: assignedSignature);
  }

  double invokeFloat(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'F', assignedSignature: assignedSignature);
  }

  double invokeDouble(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'D', assignedSignature: assignedSignature);
  }

  bool invokeBool(String methodName,
      {List? args, List<String>? assignedSignature}) {
    return invoke(methodName, args, 'Z', assignedSignature: assignedSignature);
  }

  void invokeVoid(String methodName,
      {List? args, List<String>? assignedSignature}) {
    invoke(methodName, args, 'V', assignedSignature: assignedSignature);
  }
}
