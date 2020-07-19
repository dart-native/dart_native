import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/src/android/runtime/class.dart';
import 'package:dart_native/src/android/runtime/jobject.dart';

import 'package:ffi/ffi.dart';

dynamic storeValueToPointer(
    dynamic object, Pointer<Pointer<Void>> ptr, Pointer<Pointer<Void>> typePtr) {
  if (object == null) {
    return;
  }
  if(object is double) {
    ptr.cast<Double>().value = object;
    typePtr.cast<Pointer<Utf8>>().value = Utf8.toUtf8("D");
    return;
  }

  if(object is num) {
    ptr.cast<Int32>().value = object;
    typePtr.cast<Pointer<Utf8>>().value = Utf8.toUtf8("I");
    return;
  }

  if(object is bool) {
    ptr.cast<Int32>().value = object ? 1 : 0;
    typePtr.cast<Pointer<Utf8>>().value = Utf8.toUtf8("Z");
    return;
  }

  if(object is String) {
    ptr.cast<Pointer<Utf8>>().value = Utf8.toUtf8(object);
    typePtr.cast<Pointer<Utf8>>().value = Utf8.toUtf8("Ljava/lang/String;");
    return;
  }

  if(object is Class) {
    if(object is JObject) {
      ptr.value = object.pointer;
      typePtr.cast<Pointer<Utf8>>().value =
          Utf8.toUtf8("L" + object.className + ";");
    }
    return;
  }
}

dynamic loadValueFromPointer(Pointer<Void> ptr, String returnType) {
  dynamic result;
  if (returnType == "V") {
    return;
  }
  ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
  ByteData data = ByteData.view(buffer);
  switch(returnType) {
    case "I":
      result = data.getInt32(0, Endian.host);
      break;
    case "D":
      result = data.getFloat64(0, Endian.host);
      break;
    case "Z":
      result = data.getInt8(0) != 0;
      break;
    case "Ljava/lang/String;":
      result = Utf8.fromUtf8(ptr.cast());
      break;
    default:
      result = ptr;
      break;
  }
  return result;
}
