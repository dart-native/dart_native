import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/src/common/interface_runtime.dart';
import 'package:dart_native/src/ios/interface/interface_runtime.dart';

class Interface {
  final String name;
  late InterfaceRuntime _runtime;
  late Pointer<Void> _nativeObjectPointer;
  late Map<String, String> _methodTable;

  Interface(this.name) {
    if (Platform.isIOS || Platform.isMacOS) {
      _runtime = InterfaceRuntimeObjC();
    } else if (Platform.isAndroid) {
      // TODO: Android runtime
    } else {
      throw 'Platform not supported: ${Platform.localeName}';
    }
    _nativeObjectPointer = _runtime.nativeObjectPointerForInterfaceName(name);
    if (_nativeObjectPointer == nullptr) {
      throw 'Pointer of native object is nullptr!';
    }
    _methodTable = _runtime.methodTableWithInterfaceName(name);
  }

  /// Invoke a native method synchronously.
  T invoke<T>(String method, {List? args}) {
    return _runtime.invoke(_nativeObjectPointer, _nativeMethodName(method),
        args: args);
  }

  /// Invoke a native method asynchronously.
  Future<T> invokeAsync<T>(String method, {List? args}) {
    return _runtime.invokeAsync(_nativeObjectPointer, _nativeMethodName(method),
        args: args);
  }

  /// Sets a callback for receiving method calls on this interface.
  ///
  /// The given callback will replace the currently registered callback for this
  /// interface, if any. To remove the handler, pass null as the
  /// `handler` argument.
  void setMethodCallHandler(String method, Function? function) {
    _runtime.setMethodCallHandler(name, method, function);
  }

  String _nativeMethodName(String method) {
    String? result = _methodTable[method];
    if (result == null) {
      throw 'Native method \'$method\' is not exists on interface \'$name\'';
    }
    return result;
  }
}
