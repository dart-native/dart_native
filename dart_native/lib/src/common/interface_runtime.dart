import 'dart:ffi';

/// Every platform needs to implement this abstract class to provide runtime capabilities for interface binding.
abstract class InterfaceRuntime {
  /// Returns a pointer to the native object corresponding to the interface name.
  Pointer<Void> nativeObjectPointerForInterfaceName(String name);

  /// Dart and native method mappings for interface name.
  Map<String, String> methodTableWithInterfaceName(String name);

  /// Invoke a native method synchronously.
  T invokeMethodSync<T>(Pointer<Void> nativeObjectPointer, String methodName,
      {List? args});

  /// Invoke a native method asynchronously.
  Future<T> invokeMethod<T>(Pointer<Void> nativeObjectPointer, String methodName,
      {List? args});

  /// Sets a callback for receiving method calls on this interface.
  ///
  /// The given callback will replace the currently registered callback for this
  /// interface, if any. To remove the handler, pass null as the
  /// `handler` argument.
  void setMethodCallHandler(
      String interfaceName, String method, Function? function);
}
