import 'dart:ffi';

import 'package:dart_native/src/ios/common/callback_manager.dart';
import 'package:dart_native/src/ios/common/channel_dispatch.dart';
import 'package:dart_native/src/ios/common/pointer_encoding.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:ffi/ffi.dart';

bool registerMethodCallback(
    id target, Selector selector, Function function, Pointer<Utf8> types) {
  Pointer<Void> targetPtr = target.pointer;
  Pointer<Void> selectorPtr = selector.toPointer();
  CallbackManager.shared
      .setCallbackForSelectorOnTarget(targetPtr, selectorPtr, function);
  int result = nativeAddMethod(targetPtr, selectorPtr, types, _callbackPtr);
  ChannelDispatch().registerChannelCallback('method_callback', _asyncCallback);
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
  Function function =
      CallbackManager.shared.getCallbackForSelectorOnTarget(targetPtr, selPtr);
  if (function == null) {
    return null;
  }
  List args = [];

  for (var i = 0; i < argCount; i++) {
    // types: ret, self, _cmd, args...
    String encoding = Utf8.fromUtf8(typesPtrPtr.elementAt(i + 3).value);
    Pointer<Void> ptr = argsPtrPtrPtr.elementAt(i).value.cast();
    if (!encoding.startsWith('{')) {
      ptr = ptr.cast<Pointer<Void>>().value;
    }
    dynamic value = loadValueFromPointer(ptr, encoding);
    args.add(value);
  }

  dynamic result = Function.apply(function, args);

  if (result != null) {
    String encoding = convertEncode(typesPtrPtr.elementAt(0).value);
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

void _syncCallback(
    Pointer<Pointer<Pointer<Void>>> argsPtrPtr,
    Pointer<Pointer<Void>> retPtrPtr,
    int argCount,
    Pointer<Pointer<Utf8>> typesPtrPtr,
    int stret) {
  _callback(argsPtrPtr, retPtrPtr, argCount, typesPtrPtr, stret != 0);
}

dynamic _asyncCallback(
    int argsAddr, int retAddr, int argCount, int typesAddr, bool stret) {
  Pointer<Pointer<Pointer<Void>>> argsPtrPtrPtr = Pointer.fromAddress(argsAddr);
  Pointer<Pointer<Utf8>> typesPtrPtr = Pointer.fromAddress(typesAddr);
  Pointer<Pointer<Void>> retPtrPtr = Pointer.fromAddress(retAddr);
  return _callback(argsPtrPtrPtr, retPtrPtr, argCount, typesPtrPtr, stret);
}
