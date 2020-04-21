import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

enum TypeDecoding { char, int, double, float, byte, short, long, bool, v }

Map<String, TypeDecoding> valueForTypeDecoding = {
  'C': TypeDecoding.char,
  'I': TypeDecoding.int,
  'D': TypeDecoding.double,
  'F': TypeDecoding.float,
  'B': TypeDecoding.byte,
  'S': TypeDecoding.short,
  'J': TypeDecoding.long,
  'Z': TypeDecoding.bool,
  'V': TypeDecoding.v,
};

TypeDecoding argumentSignatureDecoding(String methodSignature, int argIndex) {
  List args = methodSignature.split("");
  TypeDecoding encoding = valueForTypeDecoding[args[argIndex + 1]];
  return encoding == null ? TypeDecoding.v : encoding;
}

TypeDecoding returnSignatureDecoding(String methodSignature) {
  List args = methodSignature.split("");
  TypeDecoding encoding = valueForTypeDecoding[args[args.length - 1]];
  return encoding == null ? TypeDecoding.v : encoding;
}

dynamic storeValueToPointer(
    dynamic object, Pointer<Pointer<Void>> ptr, TypeDecoding encoding) {
  if (object == null) {
    return;
  }
  switch (encoding) {
    case TypeDecoding.char:
      int char = utf8.encode(object).first;
      ptr.cast<Uint16>().value = char;
      break;
    case TypeDecoding.int:
      ptr.cast<Int32>().value = object;
      break;
    case TypeDecoding.double:
      ptr.cast<Double>().value = object;
      break;
    case TypeDecoding.float:
      ptr.cast<Float>().value = object;
      break;
    case TypeDecoding.byte:
      ptr.cast<Int8>().value = object;
      break;
    case TypeDecoding.short:
      ptr.cast<Int16>().value = object;
      break;
    case TypeDecoding.long:
      ptr.cast<Int64>().value = object;
      break;
    case TypeDecoding.bool:
      object = object ? 1 : 0;
      ptr.cast<Int32>().value = object;
      break;
    case TypeDecoding.v:
      // TODO: Handle this case.
      break;
    default:
      break;
  }
}

dynamic loadValueFromPointer(Pointer<Void> ptr, TypeDecoding encoding) {
  dynamic result;
  if (encoding == TypeDecoding.v) {
    return;
  }
  ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
  ByteData data = ByteData.view(buffer);
  switch (encoding) {
    case TypeDecoding.int:
      result = data.getInt32(0, Endian.host);
      break;
    case TypeDecoding.bool:
      result = data.getInt8(0) != 0;
      break;
    case TypeDecoding.char:
      result = utf8.decode([data.getInt8(0)]);
      break;
    case TypeDecoding.float:
      result = data.getFloat32(0, Endian.host);
      break;
    case TypeDecoding.double:
      result = data.getFloat64(0, Endian.host);
      break;
    case TypeDecoding.byte:
      result = data.getInt8(0);
      break;
    case TypeDecoding.short:
      result = data.getInt16(0, Endian.host);
      break;
    case TypeDecoding.long:
      result = data.getInt64(0, Endian.host);
      break;
    default:
      result = 0;
  }
  return result;
}
