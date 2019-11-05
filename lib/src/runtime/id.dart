import 'dart:ffi';

import 'package:dart_objc/dart_objc.dart';
import 'package:dart_objc/src/common/channel_dispatch.dart';
import 'package:dart_objc/src/common/protocol_call.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/nsobject_protocol.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_objc/src/runtime/message.dart';

class id implements NSObjectProtocol {
  Class get isa {
    if (_ptr == null) {
      return null;
    }
    Pointer<Void> isaPtr = object_getClass(_ptr);
    return Class.fromPointer(isaPtr);
  }

  Pointer<Void> _ptr = nullptr;
  Pointer<Void> get pointer {
    return _ptr;
  }

  int _retainCount = 1;

  String get address =>
      '0x${pointer.address.toRadixString(16).padLeft(16, '0')}';

  /// Register callback function for selector in protocol.
  registerCallback(Function callback, String selName, String protoName) {
    Selector selector = Selector(selName);
    Protocol protocol = Protocol(protoName);
    if (protocol == null) {
      throw 'Protocol($protoName) never used in native code! Can not get Protocol by its name!';
    }
    return registerDelegate(this, selector, callback, protocol);
  }

  id(this._ptr) {
    if (_ptr != null && _ptr != nullptr) {
      _objects[_ptr.address] = this;
    }
    // TODO: only invoke once.
    ChannelDispatch().registerChannelCallback('object_dealloc', _dealloc);
  }

  factory id.fromPointer(Pointer<Void> ptr) {
    if (object_isClass(ptr) != 0) {
      return Class.fromPointer(ptr);
    } else {
      return NSObject.fromPointer(ptr);
    }
  }

  id retain() {
    if (this is NSObject) {
      _retainCount++;
      return perform(Selector('retain'));
    }
    return this;
  }

  /// Release NSObject instance.
  /// Subclass can override this method and call release on its dart properties.
  release() {
    if (_retainCount > 0) {
      if (this is NSObject) {
        perform(Selector('release'));
      } else if (this is Block) {
        Block_release(this.pointer);
      }
      _retainCount--;
    }
  }

  dealloc() {
    _objects.remove(pointer.address);
    removeDelegate(this);
    _ptr = nullptr;
  }

  // NSObjectProtocol

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

  @override
  String toString() {
    return '<${isa.name}: $address>';
  }

  bool operator ==(other) {
    if (other == null) return false;
    return pointer == other.pointer;
  }

  int get hashCode {
    return pointer.hashCode;
  }
}

Map<int, id> _objects = {};

_dealloc(int addr) {
  id object = _objects[addr];
  if (object != null) {
    object.dealloc();
  }
}
