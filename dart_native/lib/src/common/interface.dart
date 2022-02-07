import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/src/ios/interface/interface_runtime.dart';

abstract class InterfaceRuntime {
  Pointer<Void> hostObjectWithInterfaceName(String name);
  Map<String, String> methodTableWithInterfaceName(String name);
  dynamic invoke(String interfaceName, Pointer<Void> hostObject, String methodName, {List? args});
}

class Interface {
  String name;
  InterfaceRuntime? _runtime;
  late Pointer<Void> _hostObject;
  late Map<String, String> _methodTable;
  Interface(this.name) {
    if (Platform.isIOS || Platform.isMacOS) {
      _runtime = InterfaceRuntimeIOS();
    } else if (Platform.isAndroid) {
      // TODO: Android runtime
    }
    _hostObject = _runtime?.hostObjectWithInterfaceName(name) ?? nullptr;
    _methodTable = _runtime?.methodTableWithInterfaceName(name) ?? {};
  }

  dynamic invoke(String method, {List? args}) {
    if (_hostObject == nullptr) {
      return;
    }
    String? nativeMethodName = _methodTable[method];
    if (nativeMethodName == null) {
      throw 'Can not find native method name for \'$method\' on interface \'$name\'';
    }
    return _runtime?.invoke(name, _hostObject, nativeMethodName, args: args);
  }
}