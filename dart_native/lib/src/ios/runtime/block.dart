import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/common/pointer_wrapper.dart';
import 'package:dart_native/src/ios/common/pointer_encoding.dart';
import 'package:dart_native/src/ios/foundation/internal/objc_type_box.dart';
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

/// A wrapper class for Objective-C Block. [Block] can be used as an argument
/// to a method and as a callback.
///
/// You can create [Block] from Dart [Function], or just obtain [Block] from
/// native pointer address.
class Block extends id {
  Function function;
  NSObject _wrapper; // Block hold wrapper
  List<String> types = [];

  // TODO: This is not working when block is created by function.
  // set queue(Pointer<Void> queue) {
  //   _wrapper.perform(Selector('setQueue:'), args: [queue]);
  // }

  /// Creating a [Block] from a [Function].
  ///
  /// NOTE: The arguments of [function] should be wrapper class which can
  /// represent native type, such as [unsigned_int] or custom wrapper class with
  /// the same name.
  factory Block(Function function) {
    List<String> dartTypes = dartTypeStringForFunction(function);
    List<String> nativeTypes = nativeTypeStringForDartTypes(dartTypes);
    Pointer<Utf8> typeStringPtr = Utf8.toUtf8(nativeTypes.join(', '));
    NSObject blockWrapper =
        NSObject.fromPointer(blockCreate(typeStringPtr, _callbackPtr));
    int blockAddr = blockWrapper.perform(SEL('blockAddress'));
    Block result = Block.fromPointer(Pointer.fromAddress(blockAddr));
    free(typeStringPtr);
    result.types = dartTypes;
    result._wrapper = blockWrapper;
    result.function = function;
    _blockForAddress[result.pointer.address] = result;
    return result;
  }

  /// Creating a [Block] from a [Pointer].
  ///
  /// [Block] created by this method do NOT have [function] property.
  Block.fromPointer(Pointer<Void> ptr) : super(ptr);

  Class get superclass {
    return isa.perform(SEL('superclass'));
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

  /// Copy a new [Block] by calling `Block_copy` function.
  Block copy() {
    Pointer<Void> newPtr = Block_copy(pointer);
    if (newPtr == pointer) {
      return this;
    }
    Block result = Block.fromPointer(newPtr);
    // Block created by function.
    if (function != null) {
      result._wrapper = _wrapper;
      result.function = function;
      _blockForAddress[newPtr.address] = result;
      result.types = types;
    }
    return result;
  }

  /// Invoke the block synchronously.
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
        var arg = args[i];
        if (arg == null) {
          arg = nil;
        }
        storeValueToPointer(
            arg, argsPtrPtr.elementAt(i), typesPtrPtr.elementAt(i + 2).value);
      }
    }
    Pointer<Void> resultPtr = blockInvoke(pointer, argsPtrPtr);
    if (argsPtrPtr != nullptr.cast()) {
      free(argsPtrPtr);
    }
    dynamic result =
        loadValueFromPointer(resultPtr, typesPtrPtr.elementAt(0).value);
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
  Pointer pointer = block._wrapper.perform(SEL('typeEncodings'));
  Pointer<Pointer<Utf8>> typesPtrPtr = pointer.cast();
  for (var i = 0; i < argCount; i++) {
    // Get block args encoding. First is return type.
    Pointer<Utf8> argTypePtr =
        nativeTypeEncoding(typesPtrPtr.elementAt(i + 1).value);
    Pointer<Void> ptr = argsPtrPtrPtr.elementAt(i + argStartIndex).value.cast();
    if (argTypePtr.encodingForStruct == null) {
      ptr = ptr.cast<Pointer<Void>>().value;
    }
    dynamic arg = loadValueFromPointer(ptr, argTypePtr);
    if (i + 1 < block.types.length) {
      String dartType = block.types[i + 1];
      arg = boxingObjCBasicValue(dartType, arg);
      arg = convertFromPointer(dartType, arg);
    }
    args.add(arg);
  }

  dynamic result = Function.apply(block.function, args);

  if (result != null) {
    Pointer<Utf8> resultTypePtr =
        nativeTypeEncoding(typesPtrPtr.elementAt(0).value);
    Pointer<Pointer<Void>> realRetPtrPtr = retPtrPtr;
    if (stret) {
      realRetPtrPtr = argsPtrPtrPtr.elementAt(0).value;
    }
    if (realRetPtrPtr != nullptr) {
      PointerWrapper wrapper =
          storeValueToPointer(result, realRetPtrPtr, resultTypePtr);
      if (wrapper != null) {
        storeValueToPointer(wrapper, retPtrPtr, TypeEncodings.object);
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

// TODO: hide this method.
void removeBlockOnAddress(int addr) {
  Block block = _blockForAddress[addr];
  if (block != null) {
    block._wrapper = null;
    _blockForAddress.remove(addr);
  }
}
