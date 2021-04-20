import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/src/ios/common/pointer_wrapper.dart';
import 'package:dart_native/src/ios/dart_objc.dart';
import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';
import 'package:dart_native/src/common/native_type_box.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:ffi/ffi.dart';

// TODO: change encoding hard code string to const var.
extension TypeEncodings on Pointer<Utf8> {
  static Pointer<Pointer<Utf8>> _typeEncodings = nativeAllTypeEncodings();
  static final Pointer<Utf8> sint8 = _typeEncodings.elementAt(0).value;
  static final Pointer<Utf8> sint16 = _typeEncodings.elementAt(1).value;
  static final Pointer<Utf8> sint32 = _typeEncodings.elementAt(2).value;
  static final Pointer<Utf8> sint64 = _typeEncodings.elementAt(3).value;
  static final Pointer<Utf8> uint8 = _typeEncodings.elementAt(4).value;
  static final Pointer<Utf8> uint16 = _typeEncodings.elementAt(5).value;
  static final Pointer<Utf8> uint32 = _typeEncodings.elementAt(6).value;
  static final Pointer<Utf8> uint64 = _typeEncodings.elementAt(7).value;
  static final Pointer<Utf8> float32 = _typeEncodings.elementAt(8).value;
  static final Pointer<Utf8> float64 = _typeEncodings.elementAt(9).value;
  static final Pointer<Utf8> object = _typeEncodings.elementAt(10).value;
  static final Pointer<Utf8> cls = _typeEncodings.elementAt(11).value;
  static final Pointer<Utf8> selector = _typeEncodings.elementAt(12).value;
  static final Pointer<Utf8> block = _typeEncodings.elementAt(13).value;
  static final Pointer<Utf8> cstring = _typeEncodings.elementAt(14).value;
  static final Pointer<Utf8> v = _typeEncodings.elementAt(15).value;
  static final Pointer<Utf8> pointer = _typeEncodings.elementAt(16).value;
  static final Pointer<Utf8> b = _typeEncodings.elementAt(17).value;

  // Return encoding only if type is struct.
  String get encodingForStruct {
    String result = Utf8.fromUtf8(this);
    if (result.startsWith('{')) {
      return result;
    }
    return null;
  }

  bool get isNum {
    bool result = this == TypeEncodings.sint8 ||
        this == TypeEncodings.sint16 ||
        this == TypeEncodings.sint32 ||
        this == TypeEncodings.sint64 ||
        this == TypeEncodings.uint8 ||
        this == TypeEncodings.uint16 ||
        this == TypeEncodings.uint32 ||
        this == TypeEncodings.uint64 ||
        this == TypeEncodings.float32 ||
        this == TypeEncodings.float64;
    return result;
  }

  bool get maybeObject {
    return this == TypeEncodings.pointer || this == TypeEncodings.object;
  }

  bool get maybeBlock {
    return this == TypeEncodings.block || maybeObject;
  }

  bool get maybeId {
    return this == TypeEncodings.cls || maybeBlock;
  }

  bool get maybeSEL {
    return this == TypeEncodings.selector || this == TypeEncodings.pointer;
  }

  bool get maybeCString {
    return this == TypeEncodings.cstring || this == TypeEncodings.pointer;
  }
}

Map<Pointer<Utf8>, Function> _storeValueStrategyMap = {
  TypeEncodings.b: (Pointer ptr, dynamic object) {
    ptr.cast<Int8>().value = object;
  },
  TypeEncodings.sint8: (Pointer ptr, dynamic object) {
    ptr.cast<Int8>().value = object;
  },
  TypeEncodings.sint16: (Pointer ptr, dynamic object) {
    ptr.cast<Int16>().value = object;
  },
  TypeEncodings.sint32: (Pointer ptr, dynamic object) {
    ptr.cast<Int32>().value = object;
  },
  TypeEncodings.sint64: (Pointer ptr, dynamic object) {
    ptr.cast<Int64>().value = object;
  },
  TypeEncodings.uint8: (Pointer ptr, dynamic object) {
    ptr.cast<Uint8>().value = object;
  },
  TypeEncodings.uint16: (Pointer ptr, dynamic object) {
    ptr.cast<Uint16>().value = object;
  },
  TypeEncodings.uint32: (Pointer ptr, dynamic object) {
    ptr.cast<Uint32>().value = object;
  },
  TypeEncodings.uint64: (Pointer ptr, dynamic object) {
    ptr.cast<Uint64>().value = object;
  },
  TypeEncodings.float32: (Pointer ptr, dynamic object) {
    ptr.cast<Float>().value = object;
  },
  TypeEncodings.float64: (Pointer ptr, dynamic object) {
    ptr.cast<Double>().value = object;
  },
  TypeEncodings.float64: (Pointer ptr, dynamic object) {
    ptr.cast<Double>().value = object;
  },
  TypeEncodings.cstring: (Pointer ptr, dynamic object) {
    return storeCStringToPointer(object, ptr);
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
    Function strategy = _storeValueStrategyMap[encoding];
    if (strategy == null) {
      throw '$object not match type $encoding!';
    } else {
      return strategy(ptr, object);
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
    } else if (encoding.maybeObject) {
      NSString string = NSString(object);
      ptr.value = string.pointer;
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
  } else if (encoding.encodingForStruct != null) {
    // ptr is struct pointer
    return storeStructToPointer(ptr, object);
  } else {
    throw '$object not match type $encoding!';
  }
}

PointerWrapper storeStructToPointer(
    Pointer<Pointer<Void>> ptr, dynamic object) {
  if (object is NativeStruct) {
    Pointer<Void> result = object.addressOf.cast<Void>();
    ptr.value = result;
    return object.wrapper;
  }
  return null;
}

dynamic storeCStringToPointer(String object, Pointer<Pointer<Void>> ptr) {
  Pointer<Utf8> charPtr = Utf8.toUtf8(object);
  PointerWrapper wrapper = PointerWrapper();
  wrapper.value = charPtr.cast<Void>();
  ptr.cast<Pointer<Utf8>>().value = charPtr;
  return wrapper;
}

Map<Pointer<Utf8>, Function> _loadValueStrategyMap = {
  TypeEncodings.b: (ByteData data) {
    return data.getInt8(0);
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
  TypeEncodings.object: (Pointer<Void> ptr, bool auto) {
    return NSObject.fromPointer(ptr);
  },
  TypeEncodings.cls: (Pointer<Void> ptr, bool auto) {
    return Class.fromPointer(ptr);
  },
  TypeEncodings.selector: (Pointer<Void> ptr, bool auto) {
    return SEL.fromPointer(ptr);
  },
  TypeEncodings.block: (Pointer<Void> ptr, bool auto) {
    return Block.fromPointer(ptr);
  },
  TypeEncodings.cstring: (Pointer<Void> ptr, bool auto) {
    Pointer<Utf8> temp = ptr.cast();
    if (auto) {
      return Utf8.fromUtf8(temp);
    } else {
      // TODO: malloc and strcpy
      return temp;
    }
  },
  TypeEncodings.v: (Pointer<Void> ptr, bool auto) {
    return;
  },
};

dynamic loadValueFromPointer(Pointer<Void> ptr, Pointer<Utf8> encoding,
    [bool auto = true]) {
  dynamic result = nil;
  // num or bool
  if (encoding.isNum || encoding == TypeEncodings.b) {
    ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
    ByteData data = ByteData.view(buffer);
    result = Function.apply(_loadValueStrategyMap[encoding], [data]);
    if (encoding == TypeEncodings.b) {
      result = result != 0;
    }
  } else {
    // object
    Function strategy = _loadValueStrategyMap[encoding];
    if (strategy != null) {
      // built-in class.
      if (ptr == nullptr) {
        return nil;
      }
      result = strategy(ptr, auto);
    } else {
      // built-in struct.
      if (ptr == nullptr) {
        return null;
      }
      String structEncoding = encoding.encodingForStruct;
      if (structEncoding == null) {
        result = ptr;
      } else {
        // ptr is struct pointer
        result = loadStructFromPointer(ptr, structEncoding);
      }
    }
  }
  return result;
}

String structNameForEncoding(String encoding) {
  int index = encoding.indexOf('=');
  if (index != -1) {
    String result = encoding.substring(1, index);
    if (result.startsWith('_')) {
      result = result.substring(1);
    }
    return result;
  }
  return null;
}

NativeStruct loadStructFromPointer(Pointer<Void> ptr, String encoding) {
  NativeStruct result;
  String structName = structNameForEncoding(encoding);
  if (structName != null) {
    // struct
    switch (structName) {
      case 'CGSize':
        result = CGSize.fromPointer(ptr);
        break;
      case 'CGPoint':
        result = CGPoint.fromPointer(ptr);
        break;
      case 'CGVector':
        result = CGVector.fromPointer(ptr);
        break;
      case 'CGRect':
        result = CGRect.fromPointer(ptr);
        break;
      case 'NSRange':
        result = NSRange.fromPointer(ptr);
        break;
      case 'UIOffset':
        result = UIOffset.fromPointer(ptr);
        break;
      case 'UIEdgeInsets':
        result = UIEdgeInsets.fromPointer(ptr);
        break;
      case 'NSDirectionalEdgeInsets':
        result = NSDirectionalEdgeInsets.fromPointer(ptr);
        break;
      case 'CGAffineTransform':
        result = CGAffineTransform.fromPointer(ptr);
        break;
      default:
    }
  }
  return result..wrapper;
}

Map<String, String> _nativeTypeNameMap = {
  'unsigned_char': 'unsigned char',
  'unsigned_short': 'unsigned short',
  'unsigned_int': 'unsigned int',
  'unsigned_long': 'unsigned long',
  'long_long': 'long long',
  'unsigned_long_long': 'unsigned long long',
};

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
  'CGSize',
  'CGRect',
  'CGPoint',
  'CGVector',
  'NSRange',
  'UIOffset',
  'UIEdgeInsets',
  'NSDirectionalEdgeInsets',
  'CGAffineTransform',
  'NSInteger',
  'NSUInteger',
  'Class',
  'SEL',
];

List<String> dartTypeStringForFunction(Function function) {
  String typeString = function.runtimeType.toString();
  List<String> argsAndRet = typeString.split(' => ');
  if (argsAndRet.length == 2) {
    String args = argsAndRet.first;
    String ret = argsAndRet.last.replaceAll('Null', 'void');
    if (args.length > 2) {
      args = args.substring(1, args.length - 1);
      return '$ret, $args'.split(', ');
    } else {
      return [ret];
    }
  }
  return [];
}

List<String> nativeTypeStringForDartTypes(List<String> types) {
  return types.map((String s) {
    s = _nativeTypeNameMap[s] ?? s;
    if (s.contains('Pointer')) {
      return 'ptr';
    } else if (s.contains('CString')) {
      return 'CString';
    } else if (s.contains('Function')) {
      return 'block';
    } else if (!_nativeTypeNames.contains(s)) {
      return 'NSObject';
    }
    return s;
  }).toList();
}
