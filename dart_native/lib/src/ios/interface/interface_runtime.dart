import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/foundation/internal/native_box.dart';
import 'package:dart_native/src/ios/runtime/internal/nssubclass.dart';

class InterfaceRuntimeIOS extends InterfaceRuntime {
  InterfaceRuntimeIOS() : super();

  @override
  Pointer<Void> hostObjectWithInterfaceName(String name) {
    final ptr = NSString(name).pointer;
    return interfaceHostObjectWithName(ptr);
  }

  @override
  invoke(String interfaceName, Pointer<Void> hostObject, String methodName, {List? args}) {
    dynamic result = msgSend(hostObject, SEL(methodName), args: args);
    if (result is NativeBox || result is NSSubclass) {
      // unbox
      result = result.raw;
    }
    return result;
  }

  @override
  Map<String, String> methodTableWithInterfaceName(String name) {
    return _interfaceMetaData[name].cast<String, String>();
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