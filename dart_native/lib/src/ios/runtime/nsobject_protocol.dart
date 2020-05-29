import 'dart:ffi';

import 'package:dart_native/src/ios/dart_objc.dart';
import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/protocol.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:flutter/foundation.dart';

/// The group of methods that are fundamental to all Objective-C objects.
abstract class NSObjectProtocol implements BasicProtocol {
  /// Returns the class object for the receiver’s superclass.
  Class get superclass;

  /// Returns a Boolean value that indicates whether the receiver and a given object are equal.
  bool isEqual(NSObjectProtocol object);

  /// Returns an integer that can be used as a table address in a hash table structure.
  int get hash;

  /// Returns the receiver.
  NSObjectProtocol self();

  /// Returns a Boolean value that indicates whether the receiver is an instance of given class or an instance of any class that inherits from that class.
  bool isKind({@required Class of});

  /// Returns a Boolean value that indicates whether the receiver is an instance of a given class.
  bool isMember({@required Class of});

  /// Returns a Boolean value that indicates whether the receiver implements or inherits a method that can respond to a specified message.
  bool responds({@required SEL to});

  /// Returns a Boolean value that indicates whether the receiver conforms to a given protocol.
  bool conforms({@required Protocol to});

  /// Returns a string that describes the contents of the receiver.
  String get description;

  /// Returns a string that describes the contents of the receiver for presentation in the debugger.
  String get debugDescription;

  /// Sends a specified message to the receiver and returns the result of the message.
  dynamic perform(SEL selector, {List args});

  /// Returns a Boolean value that indicates whether the receiver does not descend from NSObject.
  bool isProxy();
}

/// Returns the class object for the receiver’s class.
Class type({@required dynamic of}) {
  if (of is NSObjectProtocol) {
    return of.perform(SEL('class'));
  } else if (of is Type) {
    return Class(of.toString());
  } else if (of is Pointer) {
    return NSObject.fromPointer(of).perform(SEL('class'));
  } else {
    return Class(of.runtimeType.toString());
  }
}
