import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/common/callback_manager.dart';
import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/common/pointer_wrapper.dart';
import 'package:dart_native/src/ios/common/pointer_encoding.dart';
import 'package:dart_native/src/ios/foundation/internal/objc_type_box.dart';
import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/internal/block_lifecycle.dart';
import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:ffi/ffi.dart';

typedef _DNBlockTypeEncodeStringC = Pointer<Utf8> Function(Pointer<Void> block);
typedef _DNBlockTypeEncodeStringD = Pointer<Utf8> Function(Pointer<Void> block);
final _DNBlockTypeEncodeStringD _blockTypeEncodeString = runtimeLib
    .lookupFunction<_DNBlockTypeEncodeStringC, _DNBlockTypeEncodeStringD>(
        'DNBlockTypeEncodeString');

/// Stands for `NSBlock` in iOS. [Block] can be used as an argument
/// to a method and as a callback.
///
/// You can create [Block] from Dart [Function], or just obtain [Block] from
/// native pointer address.
class Block extends id {
  Function function;
  NSObject _wrapper; // Block hold wrapper
  List<String> types = [];
  int sequence = -1;

  /// Creating a [Block] from a [Function].
  ///
  /// NOTE: The arguments of [function] should be wrapper class which can
  /// represent native type, such as [unsigned_int] or custom wrapper class with
  /// the same name.
  factory Block(Function function) {
    List<String> dartTypes = dartTypeStringForFunction(function);
    List<String> nativeTypes = nativeTypeStringForDartTypes(dartTypes);
    Pointer<Utf8> typeStringPtr = Utf8.toUtf8(nativeTypes.join(', '));
    Pointer<Void> blockWrapperPtr =
        blockCreate(typeStringPtr, _callbackPtr, nativePort);
    if (blockWrapperPtr == nullptr) {
      return nil;
    }
    NSObject blockWrapper = NSObject.fromPointer(blockWrapperPtr);
    int blockAddr = blockWrapper.perform(SEL('blockAddress'));
    int sequence = blockWrapper.perform(SEL('sequence'));
    Block result = Block.fromPointer(Pointer.fromAddress(blockAddr));
    free(typeStringPtr);
    result.types = dartTypes;
    result._wrapper = blockWrapper;
    result.function = function;
    result.sequence = sequence;
    if (blockForSequence[sequence] != null) {
      throw 'Already exists a block on sequence $sequence';
    }
    blockForSequence[sequence] = result;
    return result;
  }

  /// Creating a [Block] from a [Pointer].
  ///
  /// [Block] created by this method do NOT have [function] property.
  Block.fromPointer(Pointer<Void> ptr) : super(ptr);

  /// This [isa] block in iOS, but it's meaningless for a block created
  /// by Dart function.
  Class get isa {
    if (function != null) {
      return null;
    }
    return super.isa;
  }

  /// Superclass for block in iOS, but it's meaningless for a block
  /// created by Dart function.
  Class get superclass {
    if (function != null) {
      return null;
    }
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
  ///
  /// Copy a block created by Dart function is invalid, because it's used for
  /// callback from native to Dart.
  Block copy() {
    if (pointer == nullptr || function != null) {
      return null;
    }
    Pointer<Void> newPtr = Block_copy(pointer);
    if (newPtr == pointer) {
      return this;
    }
    Block result = Block.fromPointer(newPtr);
    // Block created by function.
    if (function != null) {
      result._wrapper = _wrapper;
      result.function = function;
      result.types = types;
    }
    return result;
  }

  /// Invoke the [Block] synchronously.
  ///
  /// Invoking a block created by Dart function is invalid, because it's used
  /// for callback from native to Dart.
  dynamic invoke([List args]) {
    if (pointer == nullptr || function != null) {
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
    int stringTypeBitmask = 0;
    Pointer<Pointer<Void>> argsPtrPtr = nullptr.cast();
    List<Pointer<Utf8>> structTypes = [];
    if (args != null) {
      argsPtrPtr = allocate<Pointer<Void>>(count: args.length);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          arg = nil;
        }
        if (arg is String) {
          stringTypeBitmask |= (0x1 << i);
        }
        var argTypePtr = typesPtrPtr.elementAt(i + 2).value;
        if (argTypePtr.isStruct) {
          structTypes.add(argTypePtr);
        }
        storeValueToPointer(arg, argsPtrPtr.elementAt(i), argTypePtr);
      }
    }

    Pointer<Void> resultPtr = blockInvoke(
        pointer, argsPtrPtr, nativePort, stringTypeBitmask, typesPtrPtr);
    if (argsPtrPtr != nullptr.cast()) {
      free(argsPtrPtr);
    }

    var retTypePtr = typesPtrPtr.value;
    if (retTypePtr.isStruct) {
      structTypes.add(retTypePtr);
    }
    // return value is a String.
    dynamic result;
    if (retTypePtr.isString) {
      result = loadStringFromPointer(resultPtr);
    } else {
      result = loadValueFromPointer(resultPtr, retTypePtr);
    }
    // free struct type memory (malloc on native side)
    structTypes.forEach(free);
    return result;
  }
}

Pointer<NativeFunction<BlockCallbackC>> _callbackPtr =
    Pointer.fromFunction(_syncCallback);

_callback(Pointer<Pointer<Pointer<Void>>> argsPtrPtrPtr,
    Pointer<Pointer<Void>> retPtrPtr, int argCount, bool stret, int seq) {
  // If stret, the first arg contains address of a pointer of returned struct. Other args move backwards.
  // This is the index for first argument of block in argsPtrPtrPtr list.
  int argStartIndex = stret ? 2 : 1;
  Block block = blockForSequence[seq];
  if (block == null) {
    throw 'Can\'t find block by sequence $seq';
  }
  List args = [];
  Pointer pointer = block._wrapper.perform(SEL('typeEncodings'));
  Pointer<Pointer<Utf8>> typesPtrPtr = pointer.cast();
  for (var i = 0; i < argCount; i++) {
    // Get block args encoding. First is return type.
    Pointer<Utf8> argTypePtr = typesPtrPtr.elementAt(i + 1).value;
    Pointer<Void> ptr = argsPtrPtrPtr.elementAt(i + argStartIndex).value.cast();
    if (!argTypePtr.isStruct) {
      ptr = ptr.cast<Pointer<Void>>().value;
    }
    dynamic arg = loadValueFromPointer(ptr, argTypePtr);
    if (i + 1 < block.types.length) {
      String dartType = block.types[i + 1];
      arg = boxingObjCBasicValue(dartType, arg);
      arg = objcInstanceFromPointer(dartType, arg);
    }
    args.add(arg);
  }

  dynamic result = Function.apply(block.function, args);

  if (result != null) {
    Pointer<Utf8> resultTypePtr = typesPtrPtr.elementAt(0).value;
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

int cc = 0;

void _syncCallback(Pointer<Pointer<Pointer<Void>>> argsPtrPtr,
    Pointer<Pointer<Void>> retPtr, int argCount, int stret, int seq) {
  _callback(argsPtrPtr, retPtr, argCount, stret != 0, seq);
}
