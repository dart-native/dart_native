import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/common/callback_manager.dart';
import 'package:dart_objc/src/common/channel_dispatch.dart';
import 'package:dart_objc/src/common/pointer_encoding.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/native_runtime.dart';
import 'package:dart_objc/src/runtime/selector.dart';
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
    Pointer<Void> targetPtr,
    Pointer<Void> selPtr,
    Pointer<Pointer<Pointer<Void>>> argsPtrPtr,
    Pointer<Pointer<Void>> retPtr,
    int argCount,
    Pointer<Pointer<Utf8>> typesPtrPtr) {
  Function function =
      CallbackManager.shared.getCallbackForSelectorOnTarget(targetPtr, selPtr);
  if (function == null) {
    return null;
  }
  List args = [];

  for (var i = 0; i < argCount; i++) {
    // types: ret, self, _cmd, args...
    String encoding = Utf8.fromUtf8(typesPtrPtr.elementAt(i + 3).value);
    Pointer ptr = argsPtrPtr.elementAt(i).value;
    if (!encoding.startsWith('{')) {
      ptr = ptr.cast<Pointer<Void>>().value;
    }
    dynamic value = loadValueFromPointer(ptr, encoding);
    args.add(value);
  }

  dynamic result = Function.apply(function, args);
  if (retPtr != nullptr && result != null) {
    String encoding = convertEncode(typesPtrPtr.elementAt(0).value);
    storeValueToPointer(result, retPtr, encoding);
  }
  if (result is id) {
    markAutoreleasereturnObject(result.pointer);
  }
}

void _syncCallback(
    Pointer<Void> targetPtr,
    Pointer<Void> selPtr,
    Pointer<Pointer<Pointer<Void>>> argsPtrPtr,
    Pointer<Pointer<Void>> retPtr,
    int argCount,
    Pointer<Pointer<Utf8>> typesPtrPtr) {
  _callback(targetPtr, selPtr, argsPtrPtr, retPtr, argCount, typesPtrPtr);
}

dynamic _asyncCallback(int targetAddr, int selAddr, int argsAddr, int retAddr,
    int argCount, int typesAddr) {
  Pointer<Void> targetPtr = Pointer.fromAddress(targetAddr);
  Pointer<Void> selPtr = Pointer.fromAddress(selAddr);
  Pointer<Pointer<Pointer<Void>>> argsPtrPtr = Pointer.fromAddress(argsAddr);
  Pointer<Pointer<Utf8>> typesPtrPtr = Pointer.fromAddress(typesAddr);
  Pointer<Pointer<Void>> retPtrPtr = Pointer.fromAddress(retAddr);
  return _callback(
      targetPtr, selPtr, argsPtrPtr, retPtrPtr, argCount, typesPtrPtr);
}
