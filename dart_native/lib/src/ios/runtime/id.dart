import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/runtime/internal/functions.dart';

/// Stands for `id` in iOS and macOS.
// ignore: camel_case_types
class id extends NativeObject implements NSObjectProtocol {
  /// Stands for `isa` in iOS and macOS.
  Class? get isa {
    if (_ptr == nullptr) {
      return null;
    }

    /// There is no cache because the isa pointer can be changed through objc-runtime.
    Pointer<Void> isaPtr = object_getClass(_ptr);

    /// There is a cache inside Class.
    return Class.fromPointer(isaPtr);
  }

  final Pointer<Void> _ptr;
  Pointer<Void> get pointer {
    return _ptr;
  }

  id(this._ptr);

  /// NSObjectProtocol

  /// Returns the class object for the receiver’s superclass.
  @override
  Class get superclass {
    return performSync(SEL('superclass'));
  }

  /// Returns a Boolean value that indicates whether the receiver and a given
  /// object are equal.
  @override
  bool isEqual(NSObjectProtocol object) {
    return performSync(SEL('isEqual:'), args: [object]);
  }

  /// Returns an integer that can be used as a table address in a hash table
  /// structure.
  @override
  int get hash {
    return performSync(SEL('hash'));
  }

  /// Returns the receiver.
  @override
  NSObjectProtocol self() {
    return this;
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance
  /// of given class or an instance of any class that inherits from that class.
  @override
  bool isKind({required Class of}) {
    return performSync(SEL('isKindOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance
  /// of a given class.
  @override
  bool isMember({required Class of}) {
    return performSync(SEL('isMemberOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver implements or
  /// inherits a method that can respond to a specified message.
  @override
  bool responds({required SEL to}) {
    return performSync(SEL('respondsToSelector:'), args: [to]);
  }

  /// Returns a Boolean value that indicates whether the receiver conforms to a
  /// given protocol.
  @override
  bool conforms({required Protocol to}) {
    return performSync(SEL('conformsToProtocol:'), args: [to]);
  }

  /// Returns a string that describes the contents of the receiver.
  @override
  String get description {
    return performSync(SEL('description'));
  }

  /// Returns a string that describes the contents of the receiver for
  /// presentation in the debugger.
  @override
  String get debugDescription {
    return performSync(SEL('debugDescription'));
  }

  /// Sends a specified message to the receiver and returns the result of the
  /// message.
  ///
  /// The message will consist of a [selector] and zero or more [args].
  /// Return value will be converted to Dart types when [decodeRetVal] is
  /// `true`.
  @override
  T performSync<T>(SEL selector, {List? args, bool decodeRetVal = true}) {
    return msgSendSync<T>(pointer, selector,
        args: args, decodeRetVal: decodeRetVal);
  }

  /// Sends a specified message to the receiver asynchronously using [onQueue].
  /// [onQueue] is `DispatchQueue.main` by default.
  ///
  /// The message will consist of a [selector] and zero or more [args].
  ///
  /// Returns a [Future] which completes to the received response, which may
  /// be null or nil. Return value will be converted to Dart types.
  Future<dynamic> perform(SEL selector,
      {List? args, DispatchQueue? onQueue}) async {
    return msgSend(pointer, selector, args: args, onQueue: onQueue);
  }

  /// Returns a Boolean value that indicates whether the receiver does not
  /// descend from NSObject.
  @override
  bool isProxy() {
    return performSync(SEL('isProxy'));
  }

  @override
  String toString() {
    final address = '0x${pointer.address.toRadixString(16).padLeft(16, '0')}';
    return '<${isa?.name}: $address>';
  }

  @override
  bool operator ==(other) {
    if (other is id) {
      return pointer == other.pointer;
    }
    return false;
  }

  @override
  int get hashCode {
    return pointer.hashCode;
  }
}
