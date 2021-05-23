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
  ValueType.char: 'C'.toNativeUtf8(),
  ValueType.int: 'I'.toNativeUtf8(),
  ValueType.double: 'D'.toNativeUtf8(),
  ValueType.float: 'F'.toNativeUtf8(),
  ValueType.byte: 'B'.toNativeUtf8(),
  ValueType.short: 'S'.toNativeUtf8(),
  ValueType.long: 'J'.toNativeUtf8(),
  ValueType.bool: 'Z'.toNativeUtf8(),
  ValueType.string: 'Ljava/lang/String;'.toNativeUtf8(),
};

dynamic storeValueToPointer(
    dynamic object, Pointer<Pointer<Void>> ptr, [Pointer<Pointer<Utf8>> typePtr, Pointer<Utf8> argSignature]) {
  if (object == null) {
    return;
  }

  if (object is byte) {
    ptr.cast<Int32>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.byte];
    return;
  }

  if (object is short) {
    ptr.cast<Int16>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.short];
    return;
  }

  if (object is long) {
    ptr.cast<Int64>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.long];
    return;
  }

  if (object is int) {
    ptr.cast<Int32>().value = object;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.int];
    return;
  }

  if (object is bool) {
    ptr.cast<Int32>().value = object ? 1 : 0;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.bool];
    return;
  }

  if (object is float) {
    ptr.cast<Float>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.float];
    return;
  }

  if (object is double) {
    ptr.cast<Double>().value = object;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.double];
    return;
  }

  if (object is char) {
    ptr.cast<Uint16>().value = object.raw;
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.char];
    return;
  }

  if(object is String) {
    ptr.cast<Pointer<Utf8>>().value = object.toNativeUtf8();
    typePtr?.value = argSignature != null ? argSignature : _pointerForEncode[ValueType.string];
    return;
  }

  if(object is JArray) {
    ptr.value = object.pointer;
    typePtr?.value = argSignature != null ? argSignature : object.arraySignature.toNativeUtf8();
    return;
  }

  if (object is Class) {
    if (object is JObject) {
      ptr.value = object.pointer;
      typePtr?.value = argSignature != null ? argSignature : 'L${object.className};'.toNativeUtf8();
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
  switch (returnType) {
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
      result = ptr.cast<Utf8>().toDartString;
      break;
    default:
      result = ptr;
      break;
  }
  return result;
}
