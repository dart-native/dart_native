import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_native/src/ios/common/pointer_wrapper.dart';
import 'package:dart_native/src/ios/dart_objc.dart';
import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';
import 'package:dart_native/src/ios/foundation/internal/native_type_box.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:ffi/ffi.dart';

// TODO: change encoding hard code string to const var.
enum TypeEncoding {
  v, // void
  bool, // bool, BOOL, Bool
  sint8, // char, int8_t
  uint8, // unsigned char, uint8_t
  sint16, // short, int16_t
  uint16, // unsigned short, uint16_t
  sint32, // int, int32_t
  uint32, // unsigned int, uint32_t
  sint64, // long long, int64_t
  uint64, // unsigned long long, uint64_t
  float32, // float
  float64, // double
  cstring, // char *
  object, // NSObject
  cls, // Class
  block, // Block
  pointer, // void *
  selector, // SEL, selector
  struct, // struct
}

Map<String, TypeEncoding> _valueForTypeEncoding = {
  'void': TypeEncoding.v,
  'bool': TypeEncoding.bool,
  'sint8': TypeEncoding.sint8,
  'sint16': TypeEncoding.sint16,
  'sint32': TypeEncoding.sint32,
  'sint64': TypeEncoding.sint64,
  'uint8': TypeEncoding.uint8,
  'uint16': TypeEncoding.uint16,
  'uint32': TypeEncoding.uint32,
  'uint64': TypeEncoding.uint64,
  'float32': TypeEncoding.float32,
  'float64': TypeEncoding.float64,
  'char *': TypeEncoding.cstring,
  'object': TypeEncoding.object,
  'class': TypeEncoding.cls,
  'block': TypeEncoding.block,
  'ptr': TypeEncoding.pointer,
  'selector': TypeEncoding.selector,
};

extension Helper on TypeEncoding {
  bool get isNum {
    bool result = this == TypeEncoding.sint8 ||
        this == TypeEncoding.sint16 ||
        this == TypeEncoding.sint32 ||
        this == TypeEncoding.sint64 ||
        this == TypeEncoding.uint8 ||
        this == TypeEncoding.uint16 ||
        this == TypeEncoding.uint32 ||
        this == TypeEncoding.uint64 ||
        this == TypeEncoding.float32 ||
        this == TypeEncoding.float64;
    return result;
  }

  bool get maybeObject {
    return this == TypeEncoding.pointer || this == TypeEncoding.object;
  }

  bool get maybeBlock {
    return this == TypeEncoding.block || maybeObject;
  }

  bool get maybeId {
    return this == TypeEncoding.cls || maybeBlock;
  }

  bool get maybeSEL {
    return this == TypeEncoding.selector || this == TypeEncoding.pointer;
  }

  bool get maybeCString {
    return this == TypeEncoding.cstring || this == TypeEncoding.pointer;
  }
}

extension TypeEncodingExtension on String {
  TypeEncoding get typeEncoding {
    TypeEncoding encoding = _valueForTypeEncoding[this];
    if (encoding == null && startsWith('{')) {
      encoding = TypeEncoding.struct;
    }
    return encoding;
  }
}

/// Store [object] to [ptr] which using [encoding] for automatic type conversion.
/// Returns a wrapper if [encoding] is some struct or pointer.
dynamic storeValueToPointer(
    dynamic object, Pointer<Pointer<Void>> ptr, String encoding,
    [bool auto = true]) {
  TypeEncoding typeEncoding = encoding.typeEncoding;
  if (object == null && typeEncoding == TypeEncoding.v) {
    return;
  }
  if (object is num || object is bool || object is NativeBox) {
    if (object is NativeBox) {
      object = object.value;
    }
    if (object is bool) {
      // TODO: waiting for ffi bool type support.
      object = object ? 1 : 0;
    }
    switch (typeEncoding) {
      case TypeEncoding.bool:
      case TypeEncoding.sint8:
        ptr.cast<Int8>().value = object;
        break;
      case TypeEncoding.sint16:
        ptr.cast<Int16>().value = object;
        break;
      case TypeEncoding.sint32:
        ptr.cast<Int32>().value = object;
        break;
      case TypeEncoding.sint64:
        ptr.cast<Int64>().value = object;
        break;
      case TypeEncoding.uint8:
        ptr.cast<Uint8>().value = object;
        break;
      case TypeEncoding.uint16:
        ptr.cast<Uint16>().value = object;
        break;
      case TypeEncoding.uint32:
        ptr.cast<Uint32>().value = object;
        break;
      case TypeEncoding.uint64:
        ptr.cast<Uint64>().value = object;
        break;
      case TypeEncoding.float32:
        ptr.cast<Float>().value = object;
        break;
      case TypeEncoding.float64:
        ptr.cast<Double>().value = object;
        break;
      case TypeEncoding.cstring:
        return storeCStringToPointer(object, ptr);
        break;
      default:
        throw '$object not match type $encoding!';
    }
  } else if (object is Pointer<Void> && !typeEncoding.isNum) {
    ptr.value = object;
  } else if (object is Block && typeEncoding.maybeBlock) {
    ptr.value = object.pointer;
  } else if (object is id && typeEncoding.maybeId) {
    ptr.value = object.pointer;
  } else if (object is SEL && typeEncoding.maybeSEL) {
    ptr.value = object.toPointer();
  } else if (object is Protocol) {
    ptr.value = object.toPointer();
  } else if (object is Function && typeEncoding.maybeBlock) {
    Block block = Block(object);
    ptr.value = block.pointer;
  } else if (object is String) {
    if (typeEncoding.maybeCString) {
      return storeCStringToPointer(object, ptr);
    } else if (typeEncoding.maybeObject) {
      NSString string = NSString(object);
      ptr.value = string.pointer;
    }
  } else if (object is List && typeEncoding.maybeObject) {
    ptr.value = NSArray(object).pointer;
  } else if (object is Map && typeEncoding.maybeObject) {
    ptr.value = NSDictionary(object).pointer;
  } else if (object is Set && typeEncoding.maybeObject) {
    ptr.value = NSSet(object).pointer;
  } else if (typeEncoding.maybeCString) {
    if (object is Pointer<Utf8>) {
      ptr.cast<Pointer<Utf8>>().value = object;
    } else if (object is Pointer) {
      Pointer<Void> tempPtr = object.cast<Void>();
      ptr.value = tempPtr;
    }
  } else if (typeEncoding == TypeEncoding.struct) {
    // ptr is struct pointer
    return storeStructToPointer(ptr, object);
  } else {
    throw '$object not match type $encoding!';
  }
}

dynamic storeCStringToPointer(dynamic object, Pointer<Pointer<Void>> ptr) {
  Pointer<Utf8> charPtr = Utf8.toUtf8(object);
  PointerWrapper wrapper = PointerWrapper();
  wrapper.value = charPtr.cast<Void>();
  ptr.cast<Pointer<Utf8>>().value = charPtr;
  return wrapper;
}

dynamic loadValueFromPointer(Pointer<Void> ptr, String encoding,
    [bool auto = true]) {
  dynamic result = nil;
  TypeEncoding typeEncoding = encoding.typeEncoding;
  if (typeEncoding == TypeEncoding.struct) {
    // ptr is struct pointer
    result = loadStructFromPointer(ptr, encoding);
  } else if (typeEncoding.isNum || typeEncoding == TypeEncoding.bool) {
    ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
    ByteData data = ByteData.view(buffer);
    Map<TypeEncoding, Function> functionForNumEncoding = {
      TypeEncoding.bool: data.getInt8,
      TypeEncoding.sint8: data.getInt8,
      TypeEncoding.sint16: data.getInt16,
      TypeEncoding.sint32: data.getInt32,
      TypeEncoding.sint64: data.getInt64,
      TypeEncoding.uint8: data.getUint8,
      TypeEncoding.uint16: data.getUint16,
      TypeEncoding.uint32: data.getUint32,
      TypeEncoding.uint64: data.getUint64,
      TypeEncoding.float32: data.getFloat32,
      TypeEncoding.float64: data.getFloat64,
    };
    List args = [0];
    if (typeEncoding != TypeEncoding.bool &&
        typeEncoding != TypeEncoding.sint8 &&
        typeEncoding != TypeEncoding.uint8) {
      args.add(Endian.host);
    }
    result = Function.apply(functionForNumEncoding[typeEncoding], args);
    if (typeEncoding == TypeEncoding.bool) {
      result = result != 0;
    }
  } else {
    switch (typeEncoding) {
      case TypeEncoding.object:
        result = NSObject.fromPointer(ptr);
        break;
      case TypeEncoding.cls:
        result = Class.fromPointer(ptr);
        break;
      case TypeEncoding.selector:
        result = SEL.fromPointer(ptr);
        break;
      case TypeEncoding.block:
        result = Block.fromPointer(ptr);
        break;
      case TypeEncoding.cstring:
        Pointer<Utf8> temp = ptr.cast();
        if (auto) {
          result = Utf8.fromUtf8(temp);
        } else {
          // TODO: malloc and strcpy
          result = temp;
        }
        break;
      case TypeEncoding.v:
        break;
      case TypeEncoding.pointer:
      default:
        result = ptr;
    }
  }
  return result;
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

String convertEncode(Pointer<Utf8> ptr) {
  if (_encodeCache.containsKey(ptr)) {
    return _encodeCache[ptr];
  }
  String result = Utf8.fromUtf8(ptr);
  if (!result.startsWith('{')) {
    _encodeCache[ptr] = result;
  }
  return result;
}

Map<Pointer<Utf8>, String> _encodeCache = {};

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