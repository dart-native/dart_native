import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/src/common/native_byte.dart';
import 'package:dart_native/src/darwin/common/pointer_wrapper.dart';
import 'package:dart_native/src/darwin/foundation/collection/nsarray.dart';
import 'package:dart_native/src/darwin/foundation/collection/nsdictionary.dart';
import 'package:dart_native/src/darwin/foundation/collection/nsset.dart';
import 'package:dart_native/src/darwin/foundation/internal/type_encodings.dart';
import 'package:dart_native/src/darwin/foundation/internal/native_box.dart';
import 'package:dart_native/src/darwin/foundation/internal/native_struct.dart';
import 'package:dart_native/src/darwin/foundation/nsnumber.dart';
import 'package:dart_native/src/darwin/foundation/nsstring.dart';
import 'package:dart_native/src/darwin/foundation/objc_basic_type.dart';
import 'package:dart_native/src/darwin/runtime/block.dart';
import 'package:dart_native/src/darwin/runtime/class.dart';
import 'package:dart_native/src/darwin/runtime/id.dart';
import 'package:dart_native/src/darwin/runtime/nsobject.dart';
import 'package:dart_native/src/darwin/runtime/nsobject_ref.dart';
import 'package:dart_native/src/darwin/runtime/protocol.dart';
import 'package:dart_native/src/darwin/runtime/selector.dart';
import 'package:dart_native/src/darwin/runtime/type_convertor.dart';
import 'package:ffi/ffi.dart';

Map<Pointer<Utf8>, Function> _storeBasicValueStrategyMap = {
  TypeEncodings.b: (Pointer ptr, dynamic object) {
    ptr.cast<Int8>().value = object;
  },
  TypeEncodings.sint8: (Pointer ptr, dynamic object) {
    // Type-encoding for BOOL is 'c' on macOS and 32-bit iOS simulators.
    if (object is bool) {
      object = object ? 1 : 0;
    }
    ptr.cast<Int8>().value = object.toInt();
  },
  TypeEncodings.sint16: (Pointer ptr, dynamic object) {
    ptr.cast<Int16>().value = object.toInt();
  },
  TypeEncodings.sint32: (Pointer ptr, dynamic object) {
    ptr.cast<Int32>().value = object.toInt();
  },
  TypeEncodings.sint64: (Pointer ptr, dynamic object) {
    ptr.cast<Int64>().value = object.toInt();
  },
  TypeEncodings.uint8: (Pointer ptr, dynamic object) {
    ptr.cast<Uint8>().value = object.toInt();
  },
  TypeEncodings.uint16: (Pointer ptr, dynamic object) {
    ptr.cast<Uint16>().value = object.toInt();
  },
  TypeEncodings.uint32: (Pointer ptr, dynamic object) {
    ptr.cast<Uint32>().value = object.toInt();
  },
  TypeEncodings.uint64: (Pointer ptr, dynamic object) {
    ptr.cast<Uint64>().value = object.toInt();
  },
  TypeEncodings.float32: (Pointer ptr, dynamic object) {
    ptr.cast<Float>().value = object.toDouble();
  },
  TypeEncodings.float64: (Pointer ptr, dynamic object) {
    ptr.cast<Double>().value = object.toDouble();
  },
  TypeEncodings.cstring: (Pointer ptr, dynamic object) {
    return storeCStringToPointer(object, ptr.cast<Pointer<Void>>());
  },
};

/// Store [object] to [ptr] which using [encoding] for automatic type conversion.
/// Returns a wrapper if [encoding] is some struct or pointer.
dynamic storeValueToPointer(
    dynamic object, Pointer<Pointer<Void>> ptr, Pointer<Utf8> encoding) {
  if (object == null && encoding == TypeEncodings.v) {
    return;
  }
  if (object is num || object is bool || object is NativeBox) {
    if (object is NativeBox) {
      // unwrap from box.
      object = object.raw;
    }
    if (object is bool) {
      // waiting for ffi bool type support.
      object = object ? 1 : 0;
    }
    if (encoding == TypeEncodings.object) {
      // should convert to NSNumber object
      NSNumber number = NSNumber(object);
      ptr.value = number.pointer;
    } else {
      Function? strategy = _storeBasicValueStrategyMap[encoding];
      if (strategy == null) {
        throw '$object not match type $encoding!';
      } else {
        return strategy(ptr, object);
      }
    }
  } else if (object is Pointer<Void> && !encoding.isNum) {
    ptr.value = object;
  } else if (object is Block && encoding.maybeBlock) {
    ptr.value = object.pointer;
  } else if (object is id && encoding.maybeId) {
    ptr.value = object.pointer;
  } else if (object is SEL && encoding.maybeSEL) {
    ptr.value = object.toPointer();
  } else if (object is Protocol) {
    ptr.value = object.toPointer();
  } else if (object is Function && encoding.maybeBlock) {
    Block block = Block(object);
    ptr.value = block.pointer;
  } else if (object is String) {
    if (encoding.maybeCString) {
      return storeCStringToPointer(object, ptr);
    } else if (encoding.maybeObject || encoding.isString) {
      storeStringToPointer(object, ptr);
    }
  } else if (object is List && encoding.maybeObject) {
    ptr.value = NSArray(object).pointer;
  } else if (object is Map && encoding.maybeObject) {
    ptr.value = NSDictionary(object).pointer;
  } else if (object is Set && encoding.maybeObject) {
    ptr.value = NSSet(object).pointer;
  } else if (object is NSObjectRef && encoding == TypeEncodings.pointer) {
    ptr.value = object.pointer.cast<Void>();
  } else if (object is Pointer && encoding.maybeCString) {
    Pointer<Void> tempPtr = object.cast<Void>();
    ptr.value = tempPtr;
  } else if (encoding.isStruct) {
    // ptr is struct pointer
    return storeStructToPointer(ptr, object);
  } else if (object is NativeByte) {
    ptr.value = object.raw.pointer;
  } else {
    throw '$object not match type $encoding!';
  }
}

PointerWrapper? storeStructToPointer(
    Pointer<Pointer<Void>> ptr, dynamic object) {
  if (object is NativeStruct) {
    Pointer<Void> result = object.addressOf.cast<Void>();
    ptr.value = result;
    return object.wrapper;
  }
  return null;
}

void storeStringToPointer(String object, Pointer<Pointer<Void>> ptr) {
  List<int> units = object.codeUnits;
  List<int> data = List.from(units);
  int length = units.length;
  //
  List<int> length64Bit = [
    length >> 48 & 0xffff,
    length >> 32 & 0xffff,
    length >> 16 & 0xffff,
    length & 0xffff,
  ];
  data.insertAll(0, length64Bit);
  // utf16Ptr will be freed on native side.
  Pointer<Uint16> utf16Ptr = data.toUtf16Buffer();
  ptr.value = utf16Ptr.cast();
}

dynamic storeCStringToPointer(String object, Pointer<Pointer<Void>> ptr) {
  Pointer<Utf8> charPtr = object.toNativeUtf8();
  PointerWrapper wrapper = PointerWrapper(charPtr.cast<Void>());
  ptr.cast<Pointer<Utf8>>().value = charPtr;
  return wrapper;
}

Map<Pointer<Utf8>, Function> _loadValueStrategyMap = {
  TypeEncodings.b: (ByteData data) {
    return data.getInt8(0) != 0;
  },
  TypeEncodings.sint8: (ByteData data) {
    return data.getInt8(0);
  },
  TypeEncodings.sint16: (ByteData data) {
    return data.getInt16(0, Endian.host);
  },
  TypeEncodings.sint32: (ByteData data) {
    return data.getInt32(0, Endian.host);
  },
  TypeEncodings.sint64: (ByteData data) {
    return data.getInt64(0, Endian.host);
  },
  TypeEncodings.uint8: (ByteData data) {
    return data.getUint8(0);
  },
  TypeEncodings.uint16: (ByteData data) {
    return data.getUint16(0, Endian.host);
  },
  TypeEncodings.uint32: (ByteData data) {
    return data.getUint32(0, Endian.host);
  },
  TypeEncodings.uint64: (ByteData data) {
    return data.getUint64(0, Endian.host);
  },
  TypeEncodings.float32: (ByteData data) {
    return data.getFloat32(0, Endian.host);
  },
  TypeEncodings.float64: (ByteData data) {
    return data.getFloat64(0, Endian.host);
  },
  TypeEncodings.object: (Pointer<Void> ptr, String dartType) {
    return objcInstanceFromPointer(ptr, dartType);
  },
  TypeEncodings.cls: (Pointer<Void> ptr) {
    return Class.fromPointer(ptr);
  },
  TypeEncodings.selector: (Pointer<Void> ptr) {
    return SEL.fromPointer(ptr);
  },
  TypeEncodings.block: (Pointer<Void> ptr) {
    return Block.fromPointer(ptr);
  },
  TypeEncodings.cstring: (Pointer<Void> ptr) {
    Pointer<Utf8> temp = ptr.cast();
    return temp.toDartString();
  },
  TypeEncodings.v: (Pointer<Void> ptr) {
    return;
  },
};

dynamic _handleObjCBasicValue(String type, dynamic value) {
  if (type.toLowerCase() == '$bool') {
    if (value is num) {
      return value != 0;
    }
    if (value is bool) {
      return value;
    }
    if (value is Pointer) {
      return value != nullptr;
    }
    return value != null;
  }
  if (type == '$CString') {
    return CString(value);
  }
  return value;
}

dynamic loadValueFromPointer(Pointer<Void> ptr, Pointer<Utf8> encoding,
    {String? dartType}) {
  // delete '?' for null-safety
  if (dartType != null) {
    if (dartType.endsWith('?')) {
      dartType = dartType.substring(0, dartType.length - 1);
    }
  }
  dynamic result = nil;
  do {
    // num or bool
    if (encoding.isNum || encoding == TypeEncodings.b) {
      ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
      ByteData data = ByteData.view(buffer);
      result = Function.apply(_loadValueStrategyMap[encoding]!, [data]);
      break;
    }
    // Non-basic type
    Function? strategy = _loadValueStrategyMap[encoding];
    if (strategy != null) {
      if (ptr == nullptr) {
        return nil;
      }
      // object
      if (encoding == TypeEncodings.object) {
        // known class annotated with '@native()'.
        result = strategy(ptr, dartType);
      } else {
        result = strategy(ptr);
      }
      break;
    }
    // Maybe structs
    if (ptr == nullptr) {
      return null;
    }
    // built-in struct, [ptr] is struct pointer.
    var struct = loadStructFromPointer(ptr, encoding.encodingForStruct);
    if (struct != null) {
      result = struct;
    } else {
      result = ptr;
    }
  } while (false);
  // Post-processing
  if (dartType != null) {
    result = _handleObjCBasicValue(dartType, result);
  }
  return result;
}

String? structNameForEncoding(String encoding) {
  int index = encoding.indexOf('=');
  if (index != -1) {
    String result = encoding.substring(1, index);
    // fix for `_NSRange`
    if (result.startsWith('_')) {
      result = result.substring(1);
    }
    return result;
  }
  return null;
}

String loadStringFromPointer(Pointer<Void> ptr) {
  final dataPtr = ptr.cast<Uint16>();
  // get data length
  const lengthDataSize = 4;
  final lengthData = dataPtr.asTypedList(lengthDataSize);
  int length = lengthData[0] << 48 |
      lengthData[1] << 32 |
      lengthData[2] << 16 |
      lengthData[3];
  // get utf16 data
  Uint16List data = dataPtr.elementAt(lengthDataSize).asTypedList(length);
  String result = String.fromCharCodes(data);
  // malloc dataPtr on native side, should free the memory.
  calloc.free(dataPtr);
  return result;
}

NativeStruct? loadStructFromPointer(Pointer<Void> ptr, String? encoding) {
  if (encoding == null) {
    return null;
  }
  String? structName = structNameForEncoding(encoding);
  if (structName != null) {
    // Structs registered by `@native()` can be created by `fromPointer` method.
    ConvertorFromPointer? convertor = convertorForType(structName);
    if (convertor != null) {
      return convertor(ptr);
    }
  }
  return null;
}

Map<String, String> _nativeTypeNameMap = {
  'unsigned_char': 'unsigned char',
  'unsigned_short': 'unsigned short',
  'unsigned_int': 'unsigned int',
  'unsigned_long': 'unsigned long',
  'long_long': 'long long',
  'unsigned_long_long': 'unsigned long long',
};

/// Names of native types.
///
/// The types in the list are not treated as NSObject when processing the
/// dart function signature.
List<String> _nativeTypeNames = [
  'id',
  'BOOL',
  'int',
  'unsigned int',
  'void',
  'char',
  'unsigned char',
  'short',
  'unsigned short',
  'long',
  'unsigned long',
  'long long',
  'unsigned long long',
  'float',
  'double',
  'bool',
  'size_t',
  'int8_t',
  'int16_t',
  'int32_t',
  'int64_t',
  'uint8_t',
  'uint16_t',
  'uint32_t',
  'uint64_t',
  'CGFloat',
  'NSInteger',
  'NSUInteger',
  'Class',
  'SEL',
  'CGSize',
  'NSSize',
  'CGRect',
  'NSRect',
  'CGPoint',
  'NSPoint',
  'CGVector',
  'NSRange',
  'UIOffset',
  'UIEdgeInsets',
  'NSEdgeInsets',
  'NSDirectionalEdgeInsets',
  'CGAffineTransform',
];

/// Parse signature to list of types.
///
/// These contents will be ignored: generics, whitespaces, question marks for nullable.
List<String> parseFunctionSignature(String signature) {
  List<String> result = [];
  String current = '';
  int depth = 0;
  for (var rune in signature.runes) {
    // skip generic
    if (rune == 60) {
      // '<'
      depth++;
      continue;
    } else if (rune == 62) {
      // '>'
      depth--;
      continue;
    } else if (depth > 0) {
      // skip generic body
      continue;
    } else if (rune == 32 || rune == 63) {
      // ' ' or '?'
      // skip whitespace and nullable
      continue;
    } else if (rune == 44) {
      // ','
      result.add(current);
      current = '';
    } else {
      // add char to current type
      current += String.fromCharCode(rune);
    }
  }
  // Add last
  result.add(current);
  return result;
}

List<String> dartTypeStringForFunction(Function function) {
  String typeString = function.runtimeType.toString();
  List<String> argsAndRet = typeString.split(' => ');
  List<String> result = [];
  if (argsAndRet.length == 2) {
    String args = argsAndRet.first;
    String ret = argsAndRet.last;
    if (args.length > 2) {
      args = args.substring(1, args.length - 1);
      result = parseFunctionSignature('$ret, $args');
    } else {
      result = parseFunctionSignature(ret);
    }
  }
  return result;
}

List<String> nativeTypeStringForDartTypes(List<String> types) {
  return types.map((String s) {
    s = _nativeTypeNameMap[s] ?? s;
    if (s.contains('Pointer')) {
      return 'ptr';
    } else if (s.contains('$CString')) {
      return 'CString';
    } else if (s.contains('Function')) {
      return 'block';
    } else if (!_nativeTypeNames.contains(s)) {
      if (s == 'String') {
        // special logic for String, see objc function '_parseTypeNames:error:'
        return 'String';
      } else {
        return 'NSObject';
      }
    }
    return s;
  }).toList();
}
