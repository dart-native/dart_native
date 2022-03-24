import 'dart:ffi';
import 'dart:io';

import 'package:dart_native/src/common/interface_runtime.dart';
import 'package:dart_native/src/ios/interface/interface_runtime.dart';
import 'package:dart_native/src/android/interface/interface_runtime.dart';

/// A named interface for invoking platform methods directly with arguments.
///
/// In contrast to Flutter channels, there is no need to write if-else
/// distribution logic for methods or encode and decode parameters.
/// An [Interface] can automatically converts argument lists and return values
/// between languages and supports both synchronous and asynchronous calls.
class Interface {
  final String name;
  late InterfaceRuntime _runtime;
  late Pointer<Void> _nativeObjectPointer;
  late Map<String, String> _methodTable;

  /// Creates a [Interface] with a unique [name].
  Interface(this.name) {
    if (Platform.isIOS || Platform.isMacOS) {
      _runtime = InterfaceRuntimeObjC();
    } else if (Platform.isAndroid) {
      _runtime = InterfaceRuntimeJava();
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
  ///
  /// Types of support: [num]/[String]/[List]/[Map]/[Set]/[Function]/[Pointer]/[NativeByte]/[NativeObject]
  T invokeMethodSync<T>(String method, {List? args}) {
    return _runtime.invokeMethodSync(
        _nativeObjectPointer, _nativeMethod(method),
        args: args);
  }

  /// Invoke a native method asynchronously.
  ///
  /// Types of support: [num]/[String]/[List]/[Map]/[Set]/[Function]/[Pointer]/[NativeByte]/[NativeObject]
  Future<T> invokeMethod<T>(String method, {List? args}) {
    return _runtime.invokeMethod(_nativeObjectPointer, _nativeMethod(method),
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

  String _nativeMethod(String interfaceMethodName) {
    String? result = _methodTable[interfaceMethodName];
    if (result == null) {
      throw 'Native method \'$interfaceMethodName\' is not exists on interface \'$name\'';
    }
    return result;
  }
}
