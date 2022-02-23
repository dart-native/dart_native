import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/src/ios/interface/interface_runtime.dart';

abstract class InterfaceRuntime {
  Pointer<Void> hostObjectWithInterfaceName(String name);
  Map<String, String> methodTableWithInterfaceName(String name);
  T invoke<T>(String interfaceName, Pointer<Void> hostObject, String methodName,
      {List? args});
  Future<T> invokeAsync<T>(
      String interfaceName, Pointer<Void> hostObject, String methodName,
      {List? args});
  void setMethodCallHandler(
      String interfaceName, String method, Function? function);
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
    if (_hostObject == nullptr) {
      throw 'HostObject is nullptr!';
    }
    _methodTable = _runtime.methodTableWithInterfaceName(name);
  }

  T invoke<T>(String method, {List? args}) {
    return _runtime.invoke(name, _hostObject, _nativeMethodName(method),
        args: args);
  }

  Future<T> invokeAsync<T>(String method, {List? args}) {
    return _runtime.invokeAsync(name, _hostObject, _nativeMethodName(method),
        args: args);
  }

  String _nativeMethodName(String method) {
    String? result = _methodTable[method];
    if (result == null) {
      throw 'Native method \'$method\' is not exists on interface \'$name\'';
    }
    return result;
  }

  void setMethodCallHandler(String method, Function? function) {
    _runtime.setMethodCallHandler(name, method, function);
  }
}
