import 'dart:ffi';

import 'package:dart_native/src/darwin/common/library.dart';

/// Stands for `DispatchQoS` in iOS and macOS.
///
/// The quality of service, or the execution priority, to apply to tasks.
///
/// A quality-of-service (QoS) class categorizes work to be performed on a
/// [DispatchQueue]. By specifying the quality of a task, you indicate its
/// importance to your app. When scheduling tasks, the system prioritizes those
/// that have higher service classes.
class DispatchQoS {
  final int _class;
  static const DispatchQoS background = DispatchQoS._internal(0x09);
  static const DispatchQoS utility = DispatchQoS._internal(0x11);
  static const DispatchQoS useDefault = DispatchQoS._internal(0x15);
  static const DispatchQoS userInitiated = DispatchQoS._internal(0x19);
  static const DispatchQoS userInteractive = DispatchQoS._internal(0x21);
  static const DispatchQoS unspecified = DispatchQoS._internal(0x00);

  const DispatchQoS._internal(this._class);
}

// ignore: non_constant_identifier_names
final void Function(Pointer<Void>, Pointer<Void>) dispatch_async = nativeDylib
    .lookup<NativeFunction<Void Function(Pointer<Void>, Pointer<Void>)>>(
        'dispatch_async')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Void> Function(int, int) dispatch_get_global_queue = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Int64, Uint64)>>(
        'dispatch_get_global_queue')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Void> Function() dispatch_get_main_queue = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function()>>(
        'native_dispatch_get_main_queue')
    .asFunction();

typedef DispatchWorkItem = void Function();

Pointer<Void> _mainQueue = dispatch_get_main_queue();

/// Stands for `DispatchQueue` in iOS and macOS.
/// An object that manages the execution of tasks serially or concurrently on
/// your app's main thread or on a background thread.
class DispatchQueue {
  late Pointer<Void> _queue;
  Pointer<Void> get pointer => _queue;

  DispatchQueue.global({DispatchQoS qos = DispatchQoS.useDefault}) {
    _queue = dispatch_get_global_queue(qos._class, 0);
  }

  static final DispatchQueue main = DispatchQueue._internal(_mainQueue);

  DispatchQueue._internal(this._queue);
}
