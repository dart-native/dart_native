import 'dart:convert';
import 'dart:ffi';
import 'package:dart_native/dart_native.dart';
import 'package:ffi/ffi.dart';
import 'dart:typed_data';

dynamic storeValueToPointer(
    dynamic object, Pointer<Pointer<Void>> ptr) {
  if (object == null) {
    return;
  }
  if(false) {
    ptr.cast<Float>().value = object;
  }else if (object is num || object is bool) {
    if (object is bool) {
      // TODO: waiting for ffi bool type support.
      object = object ? 1 : 0;
      ptr.cast<Int32>().value = object;
    } else if(object is int) {
      ptr.cast<Int32>().value = object;
    } else if(object is double) {
      ptr.cast<Double>().value = object;
    }
//    switch (object) {
//      case Int32:
//        ptr.cast<Int32>
//      case int :
//        ptr.cast<Int32>().value = object;
//        break;
//    }
  }else if (object is String) {
      if (object.length > 1) {
        throw '$object: Invalid String argument for native char type!';
      }
      int charC = utf8.encode(object).first;
      ptr.cast<Uint16>().value = charC;
    }
}

dynamic loadValueFromPointer(Pointer<Void> ptr, String encoding) {
  dynamic result;
  if (encoding.contains('int') ||
      encoding.contains('float') ||
      encoding.contains('double') ||
      encoding == 'boolean' ||
      encoding == 'char' ||
      encoding == 'uchar') {
    ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
    ByteData data = ByteData.view(buffer);
    switch (encoding) {
      case 'int' :
        result = data.getInt32(0, Endian.host);
        break;
      case 'boolean':
        result = data.getInt8(0) != 0;
        break;
      case 'char':
        result = utf8.decode([data.getInt8(0)]);
        break;
      case 'uchar':
          result = utf8.decode([data.getUint8(0)]);
        break;
      case 'sint8':
        result = data.getInt8(0);
        break;
      case 'sint16':
        result = data.getInt16(0, Endian.host);
        break;
      case 'sint32':
        result = data.getInt32(0, Endian.host);
        break;
      case 'sint64':
        result = data.getInt64(0, Endian.host);
        break;
      case 'uint8':
        result = data.getUint8(0);
        break;
      case 'uint16':
        result = data.getUint16(0, Endian.host);
        break;
      case 'uint32':
        result = data.getUint32(0, Endian.host);
        break;
      case 'uint64':
        result = data.getUint64(0, Endian.host);
        break;
      case 'float':
        result = data.getFloat32(0, Endian.host);
        break;
      case 'double':
        result = data.getFloat64(0, Endian.host);
        break;
      default:
        result = 0;
    }
  }
  return result;
}