import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/common/library.dart';

final int QOS_CLASS_USER_INTERACTIVE = 0x21;
final int QOS_CLASS_USER_INITIATED = 0x19;
final int QOS_CLASS_DEFAULT = 0x15;
final int QOS_CLASS_UTILITY = 0x11;
final int QOS_CLASS_BACKGROUND = 0x09;
final int QOS_CLASS_UNSPECIFIED = 0x00;


final void Function(Pointer<Void>, Pointer<Void>) dispatch_async = nativeDylib
    .lookup<NativeFunction<Void Function(Pointer<Void>, Pointer<Void>)>>(
        'dispatch_async')
    .asFunction();

final Pointer<Void> Function(int, int) dispatch_get_global_queue = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Int64, Uint64)>>(
        'dispatch_get_global_queue')
    .asFunction();

final Pointer<Void> Function() dispatch_get_main_queue = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function()>>(
        '_dispatch_get_main_queue')
    .asFunction();

typedef void DispatchWorkItem();

Pointer<Void> _mainQueue = dispatch_get_main_queue();

class DispatchQueue {
  Pointer<Void> _queue;
  Pointer<Void> get pointer => _queue;

  DispatchQueue.global({int qos}) {
    if (qos == null) {
      qos = QOS_CLASS_DEFAULT;
    }
    _queue = dispatch_get_global_queue(qos, 0);
  }

  static final DispatchQueue main = DispatchQueue._internal(_mainQueue);

  DispatchQueue._internal(this._queue); 

  /// TODO: This is not working. Waiting for ffi async callback.
  void async(DispatchWorkItem workItem) {
    Block block = Block(workItem);
    block.queue = _queue;
    dispatch_async(_queue, block.pointer);
  }
}