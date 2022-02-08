import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/src/ios/interface/interface_runtime.dart';

abstract class InterfaceRuntime {
  Pointer<Void> hostObjectWithInterfaceName(String name);
  Map<String, String> methodTableWithInterfaceName(String name);
  T invoke<T>(String interfaceName, Pointer<Void> hostObject, String methodName, {List? args});
}

class Interface {
  String name;
  late InterfaceRuntime _runtime;
  late Pointer<Void> _hostObject;
  late Map<String, String> _methodTable;
  Interface(this.name) {
    if (Platform.isIOS || Platform.isMacOS) {
      _runtime = InterfaceRuntimeObjC();
    } else if (Platform.isAndroid) {
      // TODO: Android runtime
    } else {
      throw 'Platform not supported: ${Platform.localeName}';
    }
    _hostObject = _runtime.hostObjectWithInterfaceName(name);
    _methodTable = _runtime.methodTableWithInterfaceName(name);
  }

  T invoke<T>(String method, {List? args}) {
    if (_hostObject == nullptr) {
      throw 'HostObject is nullptr!';
    }
    String? nativeMethodName = _methodTable[method];
    if (nativeMethodName == null) {
      throw 'Can not find native method name for \'$method\' on interface \'$name\'';
    }
    return _runtime.invoke(name, _hostObject, nativeMethodName, args: args);
  }
}