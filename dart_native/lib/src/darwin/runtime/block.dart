import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/darwin/common/callback_manager.dart';
import 'package:dart_native/src/darwin/common/library.dart';
import 'package:dart_native/src/darwin/common/pointer_wrapper.dart';
import 'package:dart_native/src/darwin/common/pointer_encoding.dart';
import 'package:dart_native/src/darwin/foundation/internal/type_encodings.dart';
import 'package:dart_native/src/darwin/runtime/internal/functions.dart';
import 'package:dart_native/src/darwin/runtime/internal/block_lifecycle.dart';
import 'package:dart_native/src/darwin/runtime/internal/native_runtime.dart';
import 'package:ffi/ffi.dart';

typedef _DNBlockTypeEncodeStringC = Pointer<Utf8> Function(Pointer<Void> block);
typedef _DNBlockTypeEncodeStringD = Pointer<Utf8> Function(Pointer<Void> block);
final _DNBlockTypeEncodeStringD _blockTypeEncodeString = nativeDylib
    .lookupFunction<_DNBlockTypeEncodeStringC, _DNBlockTypeEncodeStringD>(
        'DNBlockTypeEncodeString');

typedef _DNBlockTypeEncodingsC = Pointer<Pointer<Utf8>> Function(
    Pointer<Void> block);
typedef _DNBlockTypeEncodingsD = Pointer<Pointer<Utf8>> Function(
    Pointer<Void> block);
final _DNBlockTypeEncodingsD _blockTypeEncodings =
    nativeDylib.lookupFunction<_DNBlockTypeEncodingsC, _DNBlockTypeEncodingsD>(
        'DNBlockTypeEncodings');

typedef _DNBlockSequenceC = Uint64 Function(Pointer<Void> block);
typedef _DNBlockSequenceD = int Function(Pointer<Void> block);
final _DNBlockSequenceD _blockSequence = nativeDylib
    .lookupFunction<_DNBlockSequenceC, _DNBlockSequenceD>('DNBlockSequence');

/// Stands for `NSBlock` in iOS and macOS. [Block] can be used as an argument
/// to a method and as a callback.
///
/// You can create [Block] from Dart [Function], or just obtain [Block] from
/// native pointer address.

final Block nilBlock = Block.fromPointer(nullptr);

class Block extends id {
  Function? function;
  bool shouldReturnAsync = false;
  List<String> types = [];
  int sequence = -1;
  Pointer<Pointer<Utf8>> typeEncodingsPtrPtr = nullptr;

  /// Creating a [Block] from a [Function].
  ///
  /// NOTE: The arguments of [function] should be wrapper class which can
  /// represent native type, such as [unsigned_int] or custom wrapper class with
  /// the same name.
  /// When you create a [Block], you release it using [Block_release] after use.
  factory Block(Function function) {
    List<String> dartTypes = dartTypeStringForFunction(function);
    bool shouldReturnAsync = dartTypes.first.startsWith('Future');
    // block receives results from dart function asynchronously by appending a callback function to arguments.
    if (shouldReturnAsync) {
      dartTypes.add('Function');
    }
    List<String> nativeTypes = nativeTypeStringForDartTypes(dartTypes);
    Pointer<Utf8> typeStringPtr = nativeTypes.join(', ').toNativeUtf8();
    Pointer<Void> blockPtr = blockCreate(
        typeStringPtr, _callbackPtr, shouldReturnAsync ? 1 : 0, nativePort);
    assert(blockPtr != nullptr);
    if (blockPtr == nullptr) {
      return nilBlock;
    }
    int sequence = _blockSequence(blockPtr);
    Block result = Block.fromPointer(blockPtr, function: function);
    calloc.free(typeStringPtr);
    result.types = dartTypes;
    result.shouldReturnAsync = shouldReturnAsync;
    result.typeEncodingsPtrPtr = _blockTypeEncodings(blockPtr);
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
  Block.fromPointer(Pointer<Void> ptr, {this.function}) : super(ptr);

  /// This [isa] block in iOS, but it's meaningless for a block created
  /// by Dart function.
  @override
  Class? get isa {
    if (function != null) {
      throw 'Block created by Dart';
    }
    return super.isa;
  }

  /// Superclass for block in iOS, meaningless for a block
  /// created by Dart function.
  @override
  Class get superclass {
    if (function != null) {
      throw 'Block created by Dart';
      //return null;
    }
    return isa!.performSync(SEL('superclass'));
  }

  @override
  String get description {
    return toString();
  }

  @override
  String get debugDescription {
    return toString();
  }

  @override
  int get hash {
    return hashCode;
  }

  /// Copy a new [Block] by calling `Block_copy` function.
  ///
  /// Copying a block created by Dart function is invalid, because it's used for
  /// callback from native to Dart.
  Block? copy() {
    if (pointer == nullptr || function != null) {
      return null;
    }
    Pointer<Void> newPtr = Block_copy(pointer);
    if (newPtr == pointer) {
      return this;
    }
    Block result = Block.fromPointer(newPtr, function: function);
    result.types = types;
    return result;
  }

  /// Invoke the [Block] synchronously.
  ///
  /// Invoking a block created by Dart function is invalid, because it's used
  /// for callback from native to Dart.
  dynamic invoke([List? args]) {
    if (pointer == nullptr || function != null) {
      return null;
    }
    Pointer<Utf8> typesEncodingsPtr = _blockTypeEncodeString(pointer);
    Pointer<Int32> countPtr = calloc<Int32>();
    Pointer<Pointer<Utf8>> typesPtrPtr =
        nativeTypesEncoding(typesEncodingsPtr, countPtr, 0);
    int count = countPtr.value;
    calloc.free(countPtr);
    // typesPtrPtr contains return type and block itself.
    if (count != (args?.length ?? 0) + 2) {
      throw 'The number of arguments for methods dart and objc does not match';
    }
    int stringTypeBitmask = 0;
    Pointer<Pointer<Void>> argsPtrPtr = nullptr.cast();
    List<Pointer<Utf8>> structTypes = [];
    List<Pointer<Void>> blockPointers = [];
    if (args != null) {
      argsPtrPtr = calloc<Pointer<Void>>(args.length);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        arg ??= nil;
        if (arg is String) {
          stringTypeBitmask |= (0x1 << i);
        }
        var argTypePtr = typesPtrPtr.elementAt(i + 2).value;
        if (argTypePtr.isStruct) {
          structTypes.add(argTypePtr);
        }
        final argPtrPtr = argsPtrPtr.elementAt(i);
        storeValueToPointer(arg, argPtrPtr, argTypePtr);
        if (arg is Function && argTypePtr.maybeBlock) {
          blockPointers.add(argPtrPtr.value);
        }
      }
    }

    Pointer<Void> resultPtr = blockInvoke(
        pointer, argsPtrPtr, nativePort, stringTypeBitmask, typesPtrPtr);
    if (argsPtrPtr != nullptr.cast()) {
      calloc.free(argsPtrPtr);
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
    structTypes.forEach(calloc.free);
    // free typesPtrPtr (malloc on native side)
    calloc.free(typesPtrPtr);
    // release block after use (copy on native side).
    blockPointers.forEach(Block_release);
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
  Block? block = blockForSequence[seq];
  if (block == null) {
    throw 'Can\'t find block by sequence $seq';
  }
  List args = [];
  Pointer<Pointer<Utf8>> typesPtrPtr = block.typeEncodingsPtrPtr;
  for (var i = 0; i < argCount; i++) {
    // Get block args encoding. First is return type.
    Pointer<Utf8> argTypePtr = typesPtrPtr.elementAt(i + 1).value;
    Pointer<Void> ptr = argsPtrPtrPtr.elementAt(i + argStartIndex).value.cast();
    if (!argTypePtr.isStruct) {
      ptr = ptr.cast<Pointer<Void>>().value;
    }

    if (i + 1 < block.types.length) {
      String dartType = block.types[i + 1];
      dynamic arg = loadValueFromPointer(ptr, argTypePtr, dartType: dartType);
      args.add(arg);
    }
  }

  dynamic result;
  if (block.shouldReturnAsync) {
    Future future =
        Function.apply(block.function!, args.sublist(0, args.length - 1));
    Block resultCallback = args.last;
    future.then((value) {
      resultCallback.invoke([value]);
      // resultCallback is retained on objc side, we should release it after invoking.
      Block_release(resultCallback.pointer);
    });
    return;
  } else {
    result = Function.apply(block.function!, args);
  }
  // sync result
  if (result != null) {
    Pointer<Utf8> resultTypePtr = typesPtrPtr.elementAt(0).value;
    Pointer<Pointer<Void>> realRetPtrPtr = retPtrPtr;
    if (stret) {
      realRetPtrPtr = argsPtrPtrPtr.elementAt(0).value;
    }
    if (realRetPtrPtr != nullptr) {
      final resultEncoding = typesPtrPtr.elementAt(0).value;
      PointerWrapper? wrapper =
          storeValueToPointer(result, realRetPtrPtr, resultTypePtr);
      if (wrapper != null) {
        storeValueToPointer(wrapper, retPtrPtr, TypeEncodings.object);
        result = wrapper;
      }
      if (result is id) {
        retainObject(result.pointer);
      } else if (result is List || result is Map || result is Set) {
        // retain lifecycle for async invocation. release on objc when invocation finished.
        retainObject(retPtrPtr.value);
      } else if (result is Function && resultEncoding.maybeBlock) {
        // release block after use (copy on native side)
        Block_release(realRetPtrPtr.value);
      }
    }
  }
}

void _syncCallback(Pointer<Pointer<Pointer<Void>>> argsPtrPtr,
    Pointer<Pointer<Void>> retPtr, int argCount, int stret, int seq) {
  _callback(argsPtrPtr, retPtr, argCount, stret != 0, seq);
}
