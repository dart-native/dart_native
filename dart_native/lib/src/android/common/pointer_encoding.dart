import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/src/android/common/callback_manager.dart';
import 'package:dart_native/src/android/foundation/collection/jarray.dart';
import 'package:dart_native/src/android/foundation/direct_byte_buffer.dart';
import 'package:dart_native/src/android/foundation/native_type.dart';
import 'package:dart_native/src/android/runtime/jobject.dart';
import 'package:dart_native/src/common/native_byte.dart';
import 'package:ffi/ffi.dart';

import 'package:dart_native/src/android/foundation/collection/jlist.dart';
import 'package:dart_native/src/android/foundation/collection/jmap.dart';
import 'package:dart_native/src/android/foundation/collection/jset.dart';

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
  byteBuffer,
  cls,
  function,
  unknown
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
  ValueType.byteBuffer: 'Ljava/nio/ByteBuffer;'.toNativeUtf8(),
  ValueType.function:
      'Lcom/dartnative/dart_native/FunctionHandler;'.toNativeUtf8(),
  ValueType.unknown: 'Lunknown;'.toNativeUtf8(),
};

final bool is64Bit = sizeOf<IntPtr>() == 8;

dynamic storeValueToPointer(dynamic object, Pointer<Pointer<Void>> ptr,
    Pointer<Pointer<Utf8>> typePtr, Pointer<Utf8>? argSignature) {
  if (object is byte) {
    ptr.cast<Int32>().value = object.raw;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.byte]!;
    return;
  }

  if (object is short) {
    ptr.cast<Int16>().value = object.raw;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.short]!;
    return;
  }

  if (object is long) {
    ptr.cast<Int64>().value = object.raw;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.long]!;
    return;
  }

  if (object is int) {
    ptr.cast<Int32>().value = object;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.int]!;
    return;
  }

  if (object is bool) {
    ptr.cast<Int32>().value = object ? 1 : 0;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.bool]!;
    return;
  }

  if (object is float) {
    ptr.cast<Float>().value = object.raw;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.float]!;
    return;
  }

  if (object is double) {
    ptr.cast<Double>().value = object;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.double]!;
    return;
  }

  if (object is jchar) {
    ptr.cast<Uint16>().value = object.raw;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.char]!;
    return;
  }

  if (object is String) {
    ptr.cast<Pointer<Uint16>>().value = toUtf16(object);
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.string]!;
    return;
  }

  if (object is JArray) {
    ptr.value = object.pointer.cast<Void>();
    typePtr.value = argSignature ?? object.arraySignature.toNativeUtf8();
    return;
  }

  if (object is DirectByteBuffer) {
    ptr.value = object.pointer;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.byteBuffer]!;
    return;
  }

  if (object is JObject) {
    ptr.value = object.pointer;
    typePtr.value = argSignature ?? 'L${object.className};'.toNativeUtf8();
    return;
  }

  if (object is Pointer) {
    ptr.value = object.cast();
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.unknown]!;
    return;
  }

  if (object is Function) {
    final functionHandler = JObject(
        className: 'com/dartnative/dart_native/FunctionHandler',
        isInterface: true);
    registerCallback(functionHandler, object, 'invoke');
    ptr.value = functionHandler.pointer;
    typePtr.value = argSignature ?? _pointerForEncode[ValueType.function]!;
    return;
  }
}

dynamic loadValueFromPointer(Pointer<Void> ptr, String returnType,
    {bool decodeRetVal = false}) {
  if (returnType == 'V') {
    return;
  }

  if (returnType == 'java.lang.String' || returnType == 'Ljava/lang/String;') {
    return fromUtf16(ptr);
  }

  if (returnType == 'java.nio.DirectByteBuffer') {
    return NativeByte.fromRaw(DirectByteBuffer.fromPointer(ptr));
  }

  // todo optimize
  if (decodeRetVal && returnType == 'Ljava/util/Map;') {
    return JHashMap.fromPointer(ptr).raw;
  }

  if (decodeRetVal && returnType == 'Ljava/util/List;') {
    return JArrayList.fromPointer(ptr).raw;
  }

  if (decodeRetVal && returnType == 'Ljava/util/Set;') {
    return JHashSet.fromPointer(ptr).raw;
  }

  dynamic result;
  ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
  ByteData data = ByteData.view(buffer);
  switch (returnType) {
    case 'B':
      result = data.getInt8(0);
      break;
    case 'S':
      result = data.getInt16(0, Endian.host);
      break;
    case 'J':
      if (is64Bit) {
        result = data.getInt64(0, Endian.host);
      } else {
        result = ptr.cast<Int64>().value;
        calloc.free(ptr);
      }
      break;
    case 'F':
      result = data.getFloat32(0, Endian.host);
      break;
    case 'I':
      result = data.getInt32(0, Endian.host);
      break;
    case 'D':
      if (is64Bit) {
        result = data.getFloat64(0, Endian.host);
      } else {
        result = ptr.cast<Double>().value;
        calloc.free(ptr);
      }
      break;
    case 'Z':
      result = data.getInt8(0) != 0;
      break;
    case 'C':
      result = data.getInt8(0);
      break;
    default:
      result = JObject.fromPointer(ptr);
      break;
  }
  return result;
}

Pointer<Uint16> toUtf16(String? value) {
  if (value == null) {
    return nullptr.cast();
  }

  final units = value.codeUnits;
  final Pointer<Uint16> charPtr = calloc<Uint16>(units.length + 4);
  final Uint16List uintList = charPtr.asTypedList(units.length + 4);

  final valueLength = units.length;

  final lengths = [
    valueLength >> 16 & 0xFFFF,
    valueLength & 0xFFFF,
  ];
  uintList.setAll(0, lengths);
  uintList.setAll(2, units);
  uintList[units.length + 3] = 0;
  return charPtr;
}

String? fromUtf16(Pointer<Void> uint16Ptr) {
  if (uint16Ptr == nullptr) {
    return null;
  }
  int length = 0;
  for (int i = 0; i < 2; i++) {
    length += uint16Ptr.cast<Uint16>().elementAt(i).value;
  }
  Uint16List list = uint16Ptr.cast<Uint16>().asTypedList(length + 3);
  final codes = String.fromCharCodes(list.sublist(2, length + 2));
  calloc.free(uint16Ptr);
  return codes;
}
