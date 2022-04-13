import 'dart:ffi';

import 'package:dart_native/src/darwin/common/callback_manager.dart';
import 'package:dart_native/src/darwin/common/pointer_encoding.dart';
import 'package:dart_native/src/darwin/common/pointer_wrapper.dart';
import 'package:dart_native/src/darwin/foundation/internal/type_encodings.dart';
import 'package:dart_native/src/darwin/runtime/id.dart';
import 'package:dart_native/src/darwin/runtime/internal/native_runtime.dart';
import 'package:dart_native/src/darwin/runtime/selector.dart';
import 'package:ffi/ffi.dart';

bool registerMethodCallback(
    id target, SEL selector, Function function, Pointer<Utf8> types) {
  Pointer<Void> targetPtr = target.pointer;
  Pointer<Void> selectorPtr = selector.toPointer();
  CallbackManager.shared
      .setCallbackForSelectorOnTarget(targetPtr, selectorPtr, function);
  List<String> dartTypes = dartTypeStringForFunction(function);
  List<String> nativeTypes = nativeTypeStringForDartTypes(dartTypes);
  bool returnString = nativeTypes.first == 'String';
  int result = nativeAddMethod(
      targetPtr, selectorPtr, types, returnString, _callbackPtr, nativePort);
  return result != 0;
}

Pointer<NativeFunction<MethodIMPCallbackC>> _callbackPtr =
    Pointer.fromFunction(_syncCallback);

_callback(
    Pointer<Pointer<Pointer<Void>>> argsPtrPtrPtr,
    Pointer<Pointer<Void>> retPtrPtr,
    int argCount,
    Pointer<Pointer<Utf8>> typesPtrPtr,
    bool stret) {
  // If stret, the first arg contains address of a pointer of returned struct. Other args move backwards.
  // This is the index for first argument of target in argsPtrPtrPtr list.
  int argStartIndex = stret ? 3 : 2;

  Pointer<Void> targetPtr = argsPtrPtrPtr
      .elementAt(argStartIndex - 2)
      .value
      .cast<Pointer<Void>>()
      .value;
  Pointer<Void> selPtr = argsPtrPtrPtr
      .elementAt(argStartIndex - 1)
      .value
      .cast<Pointer<Void>>()
      .value;
  Function? function =
      CallbackManager.shared.getCallbackForSelectorOnTarget(targetPtr, selPtr);
  if (function == null) {
    return null;
  }
  List args = [];
  List<String> dartTypes = dartTypeStringForFunction(function);
  for (var i = 0; i < argCount; i++) {
    // types: ret, self, _cmd, args...
    Pointer<Utf8> argTypePtr = typesPtrPtr.elementAt(i + 3).value;
    Pointer<Void> ptr = argsPtrPtrPtr.elementAt(i + argStartIndex).value.cast();
    if (!argTypePtr.isStruct) {
      ptr = ptr.cast<Pointer<Void>>().value;
    }

    if (i + 1 < dartTypes.length) {
      String dartType = dartTypes[i + 1];
      dynamic arg = loadValueFromPointer(ptr, argTypePtr, dartType: dartType);
      args.add(arg);
    }
  }

  dynamic result = Function.apply(function, args);

  if (result != null) {
    Pointer<Pointer<Void>> realRetPtrPtr = retPtrPtr;
    if (stret) {
      realRetPtrPtr = argsPtrPtrPtr.elementAt(0).value;
    }
    if (realRetPtrPtr != nullptr) {
      PointerWrapper? wrapper = storeValueToPointer(
          result, realRetPtrPtr, typesPtrPtr.elementAt(0).value);
      if (wrapper != null) {
        storeValueToPointer(wrapper, retPtrPtr, TypeEncodings.object);
        result = wrapper;
      }
    }
  }
  if (result is id) {
    retainObject(result.pointer);
  } else if (result is List || result is Map || result is Set) {
    // retain lifecycle for async invocation. release on objc when invocation finished.
    retainObject(retPtrPtr.value);
  }
}

void _syncCallback(
    Pointer<Pointer<Pointer<Void>>> argsPtrPtr,
    Pointer<Pointer<Void>> retPtrPtr,
    int argCount,
    Pointer<Pointer<Utf8>> typesPtrPtr,
    int stret) {
  _callback(argsPtrPtr, retPtrPtr, argCount, typesPtrPtr, stret != 0);
}
