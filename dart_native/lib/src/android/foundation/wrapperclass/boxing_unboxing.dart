import 'package:dart_native/dart_native.dart';

dynamic boxingWrapperClass(dynamic value) {
  if (value is byte) {
    return JByte(value.raw);
  } else if (value is short) {
    return JShort(value.raw);
  } else if (value is long) {
    return JLong(value.raw);
  } else if (value is int) {
    return JInteger(value);
  } else if (value is float) {
    return JFloat(value.raw);
  } else if (value is double) {
    return JDouble(value);
  } else if (value is List) {
    return JList(value);
  } else if (value is Set) {
    return JSet(value);
  } else if (value is bool) {
    return JBoolean(value);
  } else {
    return value;
  }
}

dynamic unBoxingWrapperClass(dynamic value, String valueType) {
  switch (valueType) {
    case "java.lang.Integer":
      return JInteger.fromPointer(value).raw;
    case "java.lang.Boolean":
      return JBoolean.fromPointer(value).raw;
    case "java.lang.Byte":
      return JByte.fromPointer(value).raw;
    case "java.lang.Character":
      return JCharacter.fromPointer(value).raw;
    case "java.lang.Double":
      return JDouble.fromPointer(value).raw;
    case "java.lang.Float":
      return JFloat.fromPointer(value).raw;
    case "java.lang.Long":
      return JLong.fromPointer(value).raw;
    case "java.lang.Short":
      return JShort.fromPointer(value).raw;
    case "java.util.List":
    case "java.util.ArrayList":
      return JList.fromPointer(value).raw;
    case "java.util.Set":
    case "java.util.HashSet":
      return JSet.fromPointer(value).raw;
    case "java.lang.String":
      return value;
    default:
      return JObject(valueType.replaceAll(".", "/"), pointer: value);
  }
}
