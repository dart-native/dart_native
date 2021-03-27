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
  } else if (value is String){
    // todo support java string
    // return JObject(value);
  } else if (value is JObject) {
    return value;
  }
}

dynamic unBoxingWrapperClass(Pointer<Void> ptr, String itemType) {
  switch (itemType) {
    case "java.lang.Integer": return Integer.fromPointer(ptr).raw;
    case "java.lang.Boolean": return Boolean.fromPointer(ptr).raw;
    case "java.lang.Byte": return Byte.fromPointer(ptr).raw;
    case "java.lang.Character": return Character.fromPointer(ptr).raw;
    case "java.lang.Double": return Double.fromPointer(ptr).raw;
    case "java.lang.Float": return Float.fromPointer(ptr).raw;
    case "java.lang.Long": return Long.fromPointer(ptr).raw;
    case "java.lang.Short": return Short.fromPointer(ptr).raw;
    case "java.util.List":
    case "java.util.ArrayList":
      return JList.fromPointer(ptr).raw;
    default: return JObject(itemType?.replaceAll(".", "/"), ptr);
  }
}

