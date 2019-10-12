import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:ffi/ffi.dart';

dynamic nativeValueForEncoding(Pointer<Void> ptr, String encoding) {
  // TODO: convert return value to Dart type.
  dynamic result;
  if (encoding.contains('int') || encoding.contains('float')) {
    ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
    ByteData data = ByteData.view(buffer);
    switch (encoding) {
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
      case 'float32':
        result = data.getFloat32(0, Endian.host);
        break;
      case 'float64':
        result = data.getFloat64(0, Endian.host);
        break;
      default:
        result = 0;
    }
  } else {
    switch (encoding) {
      case 'object':
        result = NSObject.fromPointer(ptr);
        break;
      case 'class':
        result = Class.fromPointer(ptr);
        break;
      case 'selector':
        result = Selector.fromPointer(ptr);
        break;
      case 'char *':
        Pointer<Utf8> temp = ptr.cast();
        result = temp;
        break;
      case 'void':
        break;
      case 'pointer':
      default:
        result = ptr;
    }
  }

  return result;
}