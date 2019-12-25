import 'dart:ffi';

import 'package:dart_objc/src/common/callback_register.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:ffi/ffi.dart';

class NSNotification extends NSObject {}

class NSNotificationCenter extends NSObject {
  static NSNotificationCenter _defaultCenter;
  static NSNotificationCenter get defaultCenter {
    if (_defaultCenter == null) {
      NSObject result =
          Class('NSNotificationCenter').perform(Selector('defaultCenter'));
      _defaultCenter = NSNotificationCenter.fromPointer(result.pointer);
    }
    return _defaultCenter;
  }

  NSNotificationCenter.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  /// Register callback function for notification.
  /// The function must have one and only one argument (an instance of NSNotification).
  void addObserver(id observer, Function function, String name, id object) {
    Selector selector = _registerNotificationCallback(observer, function);
    if (selector == null) {
      throw 'Selector($selector) already exists when register notification!';
    }
    perform(Selector('addObserver:selector:name:object:'),
        args: [observer, selector, name, object]);
  }
}

int _notificationIndex = 0;

Selector _registerNotificationCallback(id target, Function callback) {
  String selName = 'handleNotification${_notificationIndex++}:';
  Selector selector = Selector(selName);
  String notificationEncoding = 'v24@0:8@16';
  Pointer<Utf8> types = Utf8.toUtf8(notificationEncoding);
  bool success = registerMethodCallback(target, selector, callback, types);
  free(types);
  return success ? selector : null;
}
