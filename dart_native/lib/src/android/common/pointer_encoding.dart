import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/src/android/foundation/collection/jarray.dart';
import 'package:dart_native/src/android/runtime/class.dart';
import 'package:dart_native/src/android/runtime/jobject.dart';
import 'package:dart_native/src/common/native_basic_type.dart';

import 'package:ffi/ffi.dart';

enum ValueType {
  char,
  int,
  double,
  float,
  byte,
  short,
  long,
  bool,
  v,
  string,
  cls
}

Map<ValueType, Pointer<Utf8>> _pointerForEncode = {
  ValueType.char : Utf8.toUtf8("C"),
  ValueType.int : Utf8.toUtf8("I"),
  ValueType.double : Utf8.toUtf8("D"),
  ValueType.float : Utf8.toUtf8("F"),
  ValueType.byte : Utf8.toUtf8("B"),
  ValueType.short : Utf8.toUtf8("S"),
  ValueType.long : Utf8.toUtf8("J"),
  ValueType.bool : Utf8.toUtf8("Z"),
  ValueType.string : Utf8.toUtf8("Ljava/lang/String;")
};

dynamic storeValueToPointer(
    dynamic object, Pointer<Pointer<Void>> ptr, [Pointer<Pointer<Utf8>> typePtr, Pointer<Utf8> argSignature]) {
  if (object == null) {
    return;
  }

  if(object is byte) {
    ptr.cast<Int32>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.byte];
    return;
  }

  if(object is short) {
    ptr.cast<Int16>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.short];
    return;
  }

  if(object is long) {
    ptr.cast<Int64>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.long];
    return;
  }

  if(object is int) {
    ptr.cast<Int32>().value = object;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.int];
    return;
  }

  if(object is bool) {
    ptr.cast<Int32>().value = object ? 1 : 0;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.bool];
    return;
  }

  if(object is float) {
    ptr.cast<Float>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.float];
    return;
  }

  if(object is double) {
    ptr.cast<Double>().value = object;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.double];
    return;
  }

  if(object is char) {
    ptr.cast<Uint16>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.char];
    return;
  }

  if(object is String) {
    ptr.cast<Pointer<Utf8>>().value = Utf8.toUtf8(object);
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.string];
    return;
  }

  if(object is JArray) {
    ptr.value = object.pointer;
    typePtr?.value = argSignature != null ? argSignature : Utf8.toUtf8(object.arraySignature);
    return;
  }

  if(object is Class) {
    if(object is JObject) {
      ptr.value = object.pointer;
      typePtr?.value = argSignature != null ? argSignature : Utf8.toUtf8("L" + object.className + ";");
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
    case "B":
      result = data.getInt8(0);
      break;
    case "S":
      result = data.getInt16(0, Endian.host);
      break;
    case "J":
      result = data.getInt64(0, Endian.host);
      break;
    case "F":
      result = data.getFloat32(0, Endian.host);
      break;
    case "I":
      result = data.getInt32(0, Endian.host);
      break;
    case "D":
      result = data.getFloat64(0, Endian.host);
      break;
    case "Z":
      result = data.getInt8(0) != 0;
      break;
    case "C":
      result = utf8.decode([data.getInt8(0)]);
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
