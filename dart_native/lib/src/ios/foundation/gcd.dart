import 'dart:ffi';

import 'package:dart_native/src/ios/common/library.dart';

class DispatchQoS {
  int _class;
  static final DispatchQoS background = DispatchQoS._internal(0x09);
  static final DispatchQoS utility = DispatchQoS._internal(0x11);
  static final DispatchQoS useDefault = DispatchQoS._internal(0x15);
  static final DispatchQoS userInitiated = DispatchQoS._internal(0x19);
  static final DispatchQoS userInteractive = DispatchQoS._internal(0x21);
  static final DispatchQoS unspecified = DispatchQoS._internal(0x00);

  DispatchQoS._internal(this._class);
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
        '_dispatch_get_main_queue')
    .asFunction();

typedef void DispatchWorkItem();

Pointer<Void> _mainQueue = dispatch_get_main_queue();

class DispatchQueue {
  Pointer<Void> _queue;
  Pointer<Void> get pointer => _queue;

  DispatchQueue.global({DispatchQoS qos}) {
    if (qos == null) {
      qos = DispatchQoS.useDefault;
    }
    _queue = dispatch_get_global_queue(qos._class, 0);
  }

  static final DispatchQueue main = DispatchQueue._internal(_mainQueue);

  DispatchQueue._internal(this._queue);

  /// TODO: This is not working.
  // void async(DispatchWorkItem workItem) {
  //   Block block = Block(workItem);
  //   block.queue = _queue;
  //   dispatch_async(_queue, block.pointer);
  // }
}
