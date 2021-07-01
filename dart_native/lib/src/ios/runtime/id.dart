import 'dart:ffi';

import 'package:dart_native/src/ios/dart_objc.dart';
import 'package:dart_native/src/ios/runtime/internal/functions.dart';
import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/nsobject_protocol.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_native/src/ios/runtime/message.dart';

/// Stands for `id` in iOS.
// ignore: camel_case_types
class id implements NSObjectProtocol {
  /// Stands for `isa` in iOS.
  Class get isa {
    if (_ptr == null || _ptr == nullptr) {
      return null;
    }
    Pointer<Void> isaPtr = object_getClass(_ptr);
    return Class.fromPointer(isaPtr);
  }

  Pointer<Void> _ptr = nullptr;
  Pointer<Void> get pointer {
    return _ptr;
  }

  String get _address =>
      '0x${pointer.address.toRadixString(16).padLeft(16, '0')}';

  id(this._ptr);

  // NSObjectProtocol

  /// Returns the class object for the receiver’s superclass.
  Class get superclass {
    return perform(SEL('superclass'));
  }

  /// Returns a Boolean value that indicates whether the receiver and a given
  /// object are equal.
  bool isEqual(NSObjectProtocol object) {
    return perform(SEL('isEqual:'), args: [object]);
  }

  /// Returns an integer that can be used as a table address in a hash table
  /// structure.
  int get hash {
    return perform(SEL('hash'));
  }

  /// Returns the receiver.
  NSObjectProtocol self() {
    return this;
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance
  /// of given class or an instance of any class that inherits from that class.
  bool isKind({@required Class of}) {
    return perform(SEL('isKindOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance
  /// of a given class.
  bool isMember({@required Class of}) {
    return perform(SEL('isMemberOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver implements or
  /// inherits a method that can respond to a specified message.
  bool responds({@required SEL to}) {
    return perform(SEL('respondsToSelector:'), args: [to]);
  }

  /// Returns a Boolean value that indicates whether the receiver conforms to a
  /// given protocol.
  bool conforms({@required Protocol to}) {
    return perform(SEL('conformsToProtocol:'), args: [to]);
  }

  /// Returns a string that describes the contents of the receiver.
  String get description {
    return perform(SEL('description'));
  }

  /// Returns a string that describes the contents of the receiver for
  /// presentation in the debugger.
  String get debugDescription {
    NSObject result = perform(SEL('debugDescription'));
    return NSString.fromPointer(result.pointer).raw;
  }

  /// Sends a specified message to the receiver and returns the result of the
  /// message.
  ///
  /// The message will consist of a [selector] and zero or more [args].
  /// Return value will be converted to Dart types when [decodeRetVal] is
  /// `true`.
  dynamic perform(SEL selector, {List args, bool decodeRetVal = true}) {
    return msgSend(this.pointer, selector,
        args: args, decodeRetVal: decodeRetVal);
  }

  /// Sends a specified message to the receiver asynchronously using [onQueue].
  /// [onQueue] is `DispatchQueue.main` by default.
  ///
  /// The message will consist of a [selector] and zero or more [args].
  ///
  /// Returns a [Future] which completes to the received response, which may
  /// be null or nil. Return value will be converted to Dart types.
  Future<dynamic> performAsync(SEL selector,
      {List args, DispatchQueue onQueue}) async {
    return msgSendAsync(this.pointer, selector, args: args, onQueue: onQueue);
  }

  /// Returns a Boolean value that indicates whether the receiver does not
  /// descend from NSObject.
  bool isProxy() {
    return perform(SEL('isProxy'));
  }

  @override
  String toString() {
    return '<${isa?.name}: $_address>';
  }

  bool operator ==(other) {
    return pointer == other.pointer;
  }

  int get hashCode {
    return pointer.hashCode;
  }
}
