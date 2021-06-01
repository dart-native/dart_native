import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

dynamic boxingWrapperClass(dynamic value) {
  if (value is byte) {
    return Byte(value.raw);
  } else if (value is short) {
    return Short(value.raw);
  } else if (value is long) {
    return Long(value.raw);
  } else if (value is int) {
    return Integer(value);
  } else if (value is float) {
    return Float(value.raw);
  } else if (value is double) {
    return Double(value);
  } else if (value is List) {
    return JList(value);
  } else if (value is Set) {
    return JSet(value);
  } else if (value is bool) {
    return Boolean(value);
  } else {
    return value;
  }
}

dynamic unBoxingWrapperClass(dynamic value, String valueType) {
  switch (valueType) {
    case "java.lang.Integer":
      return Integer.fromPointer(value).raw;
    case "java.lang.Boolean":
      return Boolean.fromPointer(value).raw;
    case "java.lang.Byte":
      return Byte.fromPointer(value).raw;
    case "java.lang.Character":
      return Character.fromPointer(value).raw;
    case "java.lang.Double":
      return Double.fromPointer(value).raw;
    case "java.lang.Float":
      return Float.fromPointer(value).raw;
    case "java.lang.Long":
      return Long.fromPointer(value).raw;
    case "java.lang.Short":
      return Short.fromPointer(value).raw;
    case "java.util.List":
    case "java.util.ArrayList":
      return JList.fromPointer(value).raw;
    case "java.util.Set":
    case "java.util.HashSet":
      return JSet.fromPointer(value).raw;
    case "java.lang.String":
      return value;
    default:
      return JObject(valueType?.replaceAll(".", "/") ?? "java.lang.Object",
          pointer: value);
  }
}
