import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_objc/dart_objc.dart';
import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/foundation/native_struct.dart';
import 'package:dart_objc/src/foundation/nsset.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:ffi/ffi.dart';

/// return complete closure to clear memory etc.
storeValueToPointer(dynamic object, Pointer<Pointer<Void>> ptr, String encoding,
    [bool auto = true]) {
  if (object == null && encoding == 'void') {
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
    switch (encoding) {
      case 'bool':
      case 'sint8':
        ptr.cast<Int8>().value = object;
        break;
      case 'sint16':
        ptr.cast<Int16>().value = object;
        break;
      case 'sint32':
        ptr.cast<Int32>().value = object;
        break;
      case 'sint64':
        ptr.cast<Int64>().value = object;
        break;
      case 'uint8':
        ptr.cast<Uint8>().value = object;
        break;
      case 'uint16':
        ptr.cast<Uint16>().value = object;
        break;
      case 'uint32':
        ptr.cast<Uint32>().value = object;
        break;
      case 'uint64':
        ptr.cast<Uint64>().value = object;
        break;
      case 'float32':
        ptr.cast<Float>().value = object;
        break;
      case 'float64':
        ptr.cast<Double>().value = object;
        break;
      default:
        throw '$object not match type $encoding!';
    }
  } else if (object is Pointer<Void> &&
      !encoding.contains('int') &&
      !encoding.contains('float')) {
    ptr.value = object;
  } else if (object is id &&
      (encoding == 'object' ||
          encoding == 'class' ||
          encoding == 'block' ||
          encoding == 'ptr')) {
    ptr.value = object.pointer;
  } else if (object is Selector &&
      (encoding == 'selector' || encoding == 'ptr')) {
    ptr.value = object.toPointer();
  } else if (object is Protocol) {
    ptr.value = object.toPointer();
  } else if (object is Block &&
      (encoding == 'block' || encoding == 'ptr' || encoding == 'object')) {
    ptr.value = object.pointer;
  } else if (object is Function &&
      (encoding == 'block' || encoding == 'ptr' || encoding == 'object')) {
    Block block = Block(object);
    ptr.value = block.pointer;
  } else if (object is String) {
    if (encoding == 'char *' || encoding == 'ptr') {
      Pointer<Utf8> charPtr = Utf8.toUtf8(object);
      NSObject('DOPointerWrapper')
          .autorelease()
          .perform(Selector('setPointer:'), args: [charPtr]);
      ptr.cast<Pointer<Utf8>>().value = charPtr;
    } else if (encoding == 'object') {
      NSString string = NSString(object);
      ptr.value = string.pointer;
    } else if (encoding.contains('char')) {
      if (object.length > 1) {
        throw '$object: Invalid String argument for native char type!';
      }
      int char = utf8.encode(object).first;
      if (encoding == 'uchar') {
        ptr.cast<Uint8>().value = char;
      } else if (encoding == 'char') {
        ptr.cast<Int8>().value = char;
      }
    }
  } else if (object is List || encoding == 'object') {
    ptr.value = NSArray(object).pointer;
  } else if (object is Map || encoding == 'object') {
    ptr.value = NSDictionary(object).pointer;
  } else if (object is Set || encoding == 'object') {
    ptr.value = NSSet(object).pointer;
  } else if (encoding == 'char *' || encoding == 'ptr') {
    if (object is Pointer<Utf8>) {
      ptr.cast<Pointer<Utf8>>().value = object;
    } else if (object is Pointer) {
      Pointer<Void> tempPtr = object.cast<Void>();
      ptr.value = (tempPtr);
    }
  } else if (encoding.startsWith('{')) {
    // ptr is struct pointer
    storeStructToPointer(object, ptr);
  } else {
    throw '$object not match type $encoding!';
  }
}

dynamic loadValueFromPointer(Pointer<Void> ptr, String encoding,
    [bool auto = true]) {
  dynamic result;
  if (encoding.startsWith('{')) {
    // ptr is struct pointer
    result = loadStructFromPointer(ptr, encoding);
  } else if (encoding.contains('int') ||
      encoding.contains('float') ||
      encoding == 'bool' ||
      encoding == 'char' ||
      encoding == 'uchar') {
    ByteBuffer buffer = Int64List.fromList([ptr.address]).buffer;
    ByteData data = ByteData.view(buffer);
    switch (encoding) {
      case 'bool':
        result = data.getInt8(0) != 0;
        break;
      case 'char':
        if (auto) {
          result = utf8.decode([data.getInt8(0)]);
        } else {
          result = data.getInt8(0);
        }
        break;
      case 'uchar':
        if (auto) {
          result = utf8.decode([data.getUint8(0)]);
        } else {
          result = data.getUint8(0);
        }
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
      case 'block':
        result = Block.fromPointer(ptr);
        break;
      case 'char *':
        Pointer<Utf8> temp = ptr.cast();
        if (auto) {
          result = Utf8.fromUtf8(temp);
        } else {
          result = temp;
        }
        break;
      case 'void':
        break;
      case 'ptr':
      default:
        result = ptr;
    }
  }
  return result;
}

storeStructToPointer(dynamic object, Pointer<Pointer<Void>> ptr) {
  if (object is CGSize ||
      object is CGPoint ||
      object is CGVector ||
      object is CGRect ||
      object is NSRange ||
      object is UIOffset ||
      object is UIEdgeInsets ||
      object is NSDirectionalEdgeInsets ||
      object is CGAffineTransform) {
    Pointer<Void> result = object.addressOf.cast<Void>();
    NSObject('DOPointerWrapper')
        .autorelease()
        .perform(Selector('setPointer:'), args: [result]);
    ptr.value = result;
  }
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

dynamic loadStructFromPointer(Pointer<Void> ptr, String encoding) {
  dynamic result;
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
      case '_NSRange':
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
  return result;
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

Map<String, String> encodingToNativeType = {
  'c': 'char',
  'C': 'unsignedChar',
  's': 'short',
  'S': 'unsignedShort',
  'i': 'int',
  'I': 'unsignedInt',
  'l': 'long',
  'L': 'unsignedLong',
  'q': 'longLong',
  'Q': 'unsignedLongLong',
  'f': 'float',
  'd': 'double',
  'B': 'bool',
};
