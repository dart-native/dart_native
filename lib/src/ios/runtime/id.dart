import 'dart:ffi';

import 'package:dart_native/src/ios/dart_objc.dart';
import 'package:dart_native/src/ios/common/callback_manager.dart';
import 'package:dart_native/src/ios/common/channel_dispatch.dart';
import 'package:dart_native/src/ios/common/callback_register.dart';
import 'package:dart_native/src/ios/runtime/functions.dart';
import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/native_runtime.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native/src/ios/runtime/nsobject_protocol.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_native/src/ios/runtime/message.dart';

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

  int _retainCount = 0;

  String get _address =>
      '0x${pointer.address.toRadixString(16).padLeft(16, '0')}';

  /// Register callback function for selector in protocol.
  bool registerProtocolCallback(
      Function callback, String selName, Type protocolType) {
    String protoName = protocolType.toString();
    SEL selector = SEL(selName);
    Protocol protocol = Protocol(protoName);
    if (protocol == null) {
      throw 'Protocol($protoName) never used in native code! Can not get Protocol by its name!';
    }
    Pointer<Utf8> types =
        nativeProtocolMethodTypes(protocol.toPointer(), selector.toPointer());
    return registerMethodCallback(this, selector, callback, types);
  }

  id(this._ptr) {
    if (_ptr != null && _ptr != nullptr) {
      List<id> list = _objects[_ptr.address];
      if (list == null) {
        list = [this];
        _objects[_ptr.address] = list;
      } else {
        list.add(this);
      }
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
      id temp = perform(SEL('retain'));
      _ptr = temp._ptr;
    }
    return this;
  }

  release() {
    if (_retainCount > 0) {
      if (this is NSObject) {
        perform(SEL('release'));
      } else if (this is Block) {
        Block_release(this.pointer);
      }
      _retainCount--;
    }
  }

  id autorelease() {
    id temp = perform(SEL('autorelease'));
    _ptr = temp._ptr;
    return this;
  }

  /// Clean NSObject instance.
  /// Subclass can override this method and call release on its dart properties.
  dealloc() {
    CallbackManager.shared.clearAllCallbackOnTarget(this);
    _ptr = nullptr;
  }

  // NSObjectProtocol

  /// Returns the class object for the receiver’s superclass.
  Class get superclass {
    return perform(SEL('superclass'));
  }

  /// Returns a Boolean value that indicates whether the receiver and a given object are equal.
  bool isEqual(NSObjectProtocol object) {
    return perform(SEL('isEqual:'), args: [object]);
  }

  /// Returns an integer that can be used as a table address in a hash table structure.
  int get hash {
    return perform(SEL('hash'));
  }

  /// Returns the receiver.
  NSObjectProtocol self() {
    return this;
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance of given class or an instance of any class that inherits from that class.
  bool isKind({@required Class of}) {
    return perform(SEL('isKindOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver is an instance of a given class.
  bool isMember({@required Class of}) {
    return perform(SEL('isMemberOfClass:'), args: [of]);
  }

  /// Returns a Boolean value that indicates whether the receiver implements or inherits a method that can respond to a specified message.
  bool responds({@required SEL to}) {
    return perform(SEL('respondsToSelector:'), args: [to]);
  }

  /// Returns a Boolean value that indicates whether the receiver conforms to a given protocol.
  bool conforms({@required Protocol to}) {
    return perform(SEL('conformsToProtocol:'), args: [to]);
  }

  /// Returns a string that describes the contents of the receiver.
  String get description {
    return perform(SEL('description'));
  }

  /// Returns a string that describes the contents of the receiver for presentation in the debugger.
  String get debugDescription {
    return perform(SEL('debugDescription'));
  }

  /// Sends a specified message to the receiver and returns the result of the message.
  dynamic perform(SEL selector,
      {List args, DispatchQueue onQueue, bool waitUntilDone = true}) {
    return msgSend(this, selector, args, true, onQueue, waitUntilDone);
  }

  /// Returns a Boolean value that indicates whether the receiver does not descend from NSObject.
  bool isProxy() {
    return perform(SEL('isProxy'));
  }

  @override
  String toString() {
    return '<${isa.name}: $_address>';
  }

  bool operator ==(other) {
    if (other == null) return false;
    return pointer == other.pointer;
  }

  int get hashCode {
    return pointer.hashCode;
  }
}

Map<int, List<id>> _objects = {};

_dealloc(int addr) {
  List<id> list = _objects[addr];
  if (list != null) {
    list.forEach((f) => f.dealloc());
    _objects.remove(addr);
  }
}
