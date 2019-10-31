import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/message.dart';
import 'package:dart_objc/src/runtime/protocol.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:flutter/foundation.dart';

/// The group of methods that are fundamental to all Objective-C objects.
mixin NSObjectProtocol {

  /// Returns the class object for the receiver’s superclass.
  Class get superclass {
    return perform(Selector('superclass'));
  }

  /// Returns a Boolean value that indicates whether the receiver and a given object are equal.
  bool isEqual(NSObjectProtocol object) {
    return perform(Selector('isEqual:'), args: [object]);
  }

  /// Returns an integer that can be used as a table address in a hash table structure.
  int get hash {
    return perform(Selector('hash'));
  }

  /// Returns the receiver.
  NSObjectProtocol self() {
    return this;
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance of given class or an instance of any class that inherits from that class.
  bool isKind({@required Class of}) {
    return perform(Selector('isKindOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance of a given class.
  bool isMember({@required Class of}) {
    return perform(Selector('isMemberOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver implements or inherits a method that can respond to a specified message.
  bool responds({@required Selector to}) {
    return perform(Selector('respondsToSelector:'), args: [to]);
  }

  /// Returns a Boolean value that indicates whether the receiver conforms to a given protocol.
  bool conforms({@required Protocol to}) {
    return perform(Selector('conformsToProtocol:'), args: [to]);
  }

  /// Returns a string that describes the contents of the receiver.
  String get description {
    return perform(Selector('description'));
  }

  /// Returns a string that describes the contents of the receiver for presentation in the debugger.
  String get debugDescription {
    return perform(Selector('debugDescription'));
  }

  /// Sends a specified message to the receiver and returns the result of the message.
  dynamic perform(Selector selector, {List args}) {
    return msgSend(this, selector, args);
  }

  /// Returns a Boolean value that indicates whether the receiver does not descend from NSObject.
  bool isProxy() {
    return perform(Selector('isProxy'));
  }

  NSObjectProtocol retain() {
    return perform(Selector('retain'));
  }

  release() {
    perform(Selector('release'));
  }
}

/// Returns the class object for the receiver’s class.
Class type({@required dynamic of}) {
  if (of is NSObjectProtocol) {
    return of.perform(Selector('class'));
  } else if (of is Type) {
    return Class(of.toString());
  } else {
    return Class(of.runtimeType.toString());
  }
}