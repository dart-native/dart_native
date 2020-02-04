import 'dart:ffi';

import 'package:dart_native/src/ios/common/channel_dispatch.dart';
import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/common/pointer_wrapper.dart';
import 'package:dart_native/src/ios/foundation/internal/native_type_box.dart';
import 'package:dart_native/src/ios/common/pointer_encoding.dart';
import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/functions.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:ffi/ffi.dart';

typedef _DNBlockTypeEncodeStringC = Pointer<Utf8> Function(Pointer<Void> block);
typedef _DNBlockTypeEncodeStringD = Pointer<Utf8> Function(Pointer<Void> block);
final _DNBlockTypeEncodeStringD _blockTypeEncodeString = runtimeLib
    .lookupFunction<_DNBlockTypeEncodeStringC, _DNBlockTypeEncodeStringD>(
        'DNBlockTypeEncodeString');

Map<int, Block> _blockForAddress = {};

class Block extends id {
  Function function;
  NSObject _wrapper; // Block hold wrapper
  List<String> types = [];

  /// TODO: This is not working. Waiting for ffi async callback.
  // set queue(Pointer<Void> queue) {
  //   _wrapper.perform(Selector('setQueue:'), args: [queue]);
  // }

  factory Block(Function function) {
    List<String> types = _typeStringForFunction(function);
    Pointer<Utf8> typeStringPtr = Utf8.toUtf8(types.join(', '));
    NSObject blockWrapper =
        NSObject.fromPointer(blockCreate(typeStringPtr, _callbackPtr));
    int blockAddr = blockWrapper.perform(Selector('blockAddress'));
    Block result = Block._internal(Pointer.fromAddress(blockAddr));
    free(typeStringPtr);
    result.types = types;
    result._wrapper = blockWrapper;
    result.function = function;
    _blockForAddress[result.pointer.address] = result;
    return result;
  }

  factory Block.fromPointer(Pointer<Void> ptr) {
    return Block._internal(ptr);
  }

  Block._internal(Pointer<Void> ptr) : super(ptr) {
    ChannelDispatch().registerChannelCallback('block_invoke', _asyncCallback);
  }

  Class get superclass {
    return isa.perform(Selector('superclass'));
  }

  String get description {
    return toString();
  }

  String get debugDescription {
    return toString();
  }

  int get hash {
    return hashCode;
  }

  Block copy() {
    Pointer<Void> newPtr = Block_copy(pointer);
    if (newPtr == pointer) {
      return this;
    }
    Block result = Block._internal(newPtr);
    // Block created by function.
    if (function != null) {
      result._wrapper = _wrapper;
      result.function = function;
      _blockForAddress[newPtr.address] = result;
      result.types = types;
    }
    return result;
  }

  dealloc() {
    _wrapper = null;
    _blockForAddress.remove(pointer.address);
    super.dealloc();
  }

  dynamic invoke([List args]) {
    if (pointer == nullptr) {
      return null;
    }
    Pointer<Utf8> typesEncodingsPtr = _blockTypeEncodeString(pointer);
    Pointer<Int32> countPtr = allocate<Int32>();
    Pointer<Pointer<Utf8>> typesPtrPtr =
        nativeTypesEncoding(typesEncodingsPtr, countPtr, 0);
    int count = countPtr.value;
    free(countPtr);
    // typesPtrPtr contains return type and block itself.
    if (count != (args?.length ?? 0) + 2) {
      throw 'Args Count NOT match';
    }

    Pointer<Pointer<Void>> argsPtrPtr = nullptr.cast();
    if (args != null) {
      argsPtrPtr = allocate<Pointer<Void>>(count: args.length);
      for (var i = 0; i < args.length; i++) {
        if (args[i] == null) {
          throw 'One of args list is null';
        }
        String encoding = Utf8.fromUtf8(typesPtrPtr.elementAt(i + 2).value);
        storeValueToPointer(args[i], argsPtrPtr.elementAt(i), encoding);
      }
    }
    Pointer<Void> resultPtr = blockInvoke(pointer, argsPtrPtr);
    if (argsPtrPtr != nullptr.cast()) {
      free(argsPtrPtr);
    }
    String encoding = Utf8.fromUtf8(typesPtrPtr.elementAt(0).value);
    dynamic result = loadValueFromPointer(resultPtr, encoding);
    return result;
  }
}

Pointer<NativeFunction<BlockCallbackC>> _callbackPtr =
    Pointer.fromFunction(_syncCallback);

_callback(Pointer<Pointer<Pointer<Void>>> argsPtrPtrPtr,
    Pointer<Pointer<Void>> retPtrPtr, int argCount, bool stret) {
  // If stret, the first arg contains address of a pointer of returned struct. Other args move backwards.
  // This is the index for first argument of block in argsPtrPtrPtr list.
  int argStartIndex = stret ? 2 : 1;

  Pointer<Void> blockPtr = argsPtrPtrPtr
      .elementAt(argStartIndex - 1)
      .value
      .cast<Pointer<Void>>()
      .value;
  Block block = _blockForAddress[blockPtr.address];
  if (block == null) {
    return null;
  }
  List args = [];
  Pointer pointer = block._wrapper.perform(Selector('typeEncodings'));
  Pointer<Pointer<Utf8>> typesPtrPtr = pointer.cast();
  for (var i = 0; i < argCount; i++) {
    // Get block args encoding. First is return type.
    Pointer<Utf8> argTypePtr =
        nativeTypeEncoding(typesPtrPtr.elementAt(i + 1).value);
    String encoding = convertEncode(argTypePtr);
    Pointer<Void> ptr = argsPtrPtrPtr.elementAt(i + argStartIndex).value.cast();
    if (!encoding.startsWith('{')) {
      ptr = ptr.cast<Pointer<Void>>().value;
    }
    dynamic value = loadValueFromPointer(ptr, encoding);
    dynamic arg = boxingBasicValue(block.types[i + 1], value);
    args.add(arg);
  }
  dynamic result = Function.apply(block.function, args);

  if (result != null) {
    Pointer<Utf8> resultTypePtr =
        nativeTypeEncoding(typesPtrPtr.elementAt(0).value);
    String encoding = convertEncode(resultTypePtr);
    Pointer<Pointer<Void>> realRetPtrPtr = retPtrPtr;
    if (stret) {
      realRetPtrPtr = argsPtrPtrPtr.elementAt(0).value;
    }
    if (realRetPtrPtr != nullptr) {
      PointerWrapper wrapper =
          storeValueToPointer(result, realRetPtrPtr, encoding);
      if (wrapper != null) {
        storeValueToPointer(wrapper, retPtrPtr, 'object');
        result = wrapper;
      }
    }
  }
  if (result is id) {
    markAutoreleasereturnObject(result.pointer);
  }
}

void _syncCallback(Pointer<Pointer<Pointer<Void>>> argsPtrPtr,
    Pointer<Pointer<Void>> retPtr, int argCount, int stret) {
  _callback(argsPtrPtr, retPtr, argCount, stret != 0);
}

_asyncCallback(int argsAddr, int retAddr, int argCount, bool stret) {
  Pointer<Pointer<Pointer<Void>>> argsPtrPtrPtr = Pointer.fromAddress(argsAddr);
  Pointer<Pointer<Void>> retPtrPtr = Pointer.fromAddress(retAddr);
  _callback(argsPtrPtrPtr, retPtrPtr, argCount, stret);
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
  'Selector'
];

List<String> _typeStringForFunction(Function function) {
  String typeString = function.runtimeType.toString();
  List<String> argsAndRet = typeString.split(' => ');
  if (argsAndRet.length == 2) {
    String args = argsAndRet.first;
    String ret = argsAndRet.last.replaceAll('Null', 'void');
    if (args.length > 2) {
      args = args.substring(1, args.length - 1);
      _nativeTypeNameMap.forEach((String dartTypeName, String nativeTypeName) {
        args = args.replaceAll(dartTypeName, nativeTypeName);
      });
      return '$ret, $args'.split(', ').map((String s) {
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
    } else {
      return [ret];
    }
  }
  return [];
}
