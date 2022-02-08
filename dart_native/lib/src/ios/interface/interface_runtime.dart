import 'dart:async';
import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/runtime/internal/nssubclass.dart';

class InterfaceRuntimeObjC extends InterfaceRuntime {
  @override
  Pointer<Void> hostObjectWithInterfaceName(String name) {
    final ptr = NSString(name).pointer;
    return interfaceHostObjectWithName(ptr);
  }

  @override
  Map<String, String> methodTableWithInterfaceName(String name) {
    return _interfaceMetaData[name].cast<String, String>();
  }

  @override
  T invoke<T>(String interfaceName, Pointer<Void> hostObject, String methodName, {List? args}) {
    dynamic result = msgSend(hostObject, SEL(methodName), args: args);
    return _postprocessResult<T>(result);
  }

  @override
  Future<T> invokeAsync<T>(String interfaceName, Pointer<Void> hostObject, String methodName, {List? args}) {
    return msgSendAsync<dynamic>(hostObject, SEL(methodName), args: args).then((value){
      return _postprocessResult<T>(value);
    });
  }

  T _postprocessResult<T>(dynamic result) {
    if (result is NSSubclass) {
      // unbox
      result = result.raw;
    }
    if (result is NSObject && result.isKind(of: Class('NSNumber'))) {
      // The type of result is NSObject, we should unbox it.
      final number = NSNumber.fromPointer(result.pointer);
      if (T == int || T == double) {
        return number.raw;
      }
    }
    return result;
  }
}

final Pointer<Void> Function(Pointer<Void>) interfaceHostObjectWithName = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
        'DNInterfaceHostObjectWithName')
    .asFunction();

final Pointer<Void> Function() interfaceAllMetaData =
    nativeDylib
        .lookup<NativeFunction<Pointer<Void> Function()>>(
            'DNInterfaceAllMetaData')
        .asFunction();

Map _mapForInterfaceMetaData() {
  Pointer<Void> ptr = interfaceAllMetaData();
  return NSDictionary.fromPointer(ptr).raw;
}

final Map _interfaceMetaData = _mapForInterfaceMetaData();