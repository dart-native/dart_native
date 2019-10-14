import 'dart:ffi';

import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/message.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/nsobject_protocol.dart';
import 'package:dart_objc/src/runtime/selector.dart';

class id implements NSObjectProtocol {
  Class get isa {
    Pointer<Void> isaPtr = object_getClass(_ptr);
    return Class.fromPointer(isaPtr);
  }
  Pointer<Void> get pointer {
    return _ptr;
  }
  Pointer<Void> _ptr;

  id(this._ptr);

  factory id.fromPointer(Pointer<Void> ptr) {
    if (object_isClass(ptr) != 0) {
      return Class.fromPointer(ptr);
    } else {
      return NSObject.fromPointer(ptr);
    }
  }

  @override
  performSelector(Selector selector, [List args]) {
    return msgSend(this, selector, args);
  }

  @override
  String toString() {
    return '${isa.name}:<${_ptr.address}>';
  }

  bool operator ==(other) {
    if (other == null) return false;
    return pointer == other.pointer;
  }

  int get hashCode {
    return pointer.hashCode;
  }
}
