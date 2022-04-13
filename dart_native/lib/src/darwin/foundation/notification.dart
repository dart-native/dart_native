import 'dart:ffi';

import 'package:dart_native/src/darwin/common/callback_register.dart';
import 'package:dart_native/src/darwin/runtime/class.dart';
import 'package:dart_native/src/darwin/runtime/nsobject.dart';
import 'package:dart_native/src/darwin/runtime/id.dart';
import 'package:dart_native/src/darwin/runtime/selector.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSNotification` in iOS and macOS.
@native()
class NSNotification extends NSObject {
  NSNotification.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}

class NSNotificationCenter extends NSObject {
  static NSNotificationCenter? _defaultCenter;
  static NSNotificationCenter get defaultCenter {
    if (_defaultCenter == null) {
      NSObject result =
          Class('NSNotificationCenter').perform(SEL('defaultCenter'));
      _defaultCenter = NSNotificationCenter.fromPointer(result.pointer);
    }
    return _defaultCenter!;
  }

  NSNotificationCenter.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  /// Register callback function for notification.
  /// The function must have one and only one argument (an instance of NSNotification).
  void addObserver(id observer, Function function, String name, id object) {
    SEL? selector = _registerNotificationCallback(observer, function);
    if (selector == null) {
      throw 'Selector($selector) already exists when register notification!';
    }
    perform(SEL('addObserver:selector:name:object:'),
        args: [observer, selector, name, object]);
  }
}

int _notificationIndex = 0;

SEL? _registerNotificationCallback(id target, Function callback) {
  String selName = 'handleNotification${_notificationIndex++}:';
  SEL selector = SEL(selName);
  String notificationEncoding = 'v24@0:8@16';
  Pointer<Utf8> types = notificationEncoding.toNativeUtf8();
  bool success = registerMethodCallback(target, selector, callback, types);
  calloc.free(types);
  return success ? selector : null;
}
